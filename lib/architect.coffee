# Requires
Polyfills = {}
for type in ['ajax', 'jsonp']
  Polyfills[type] = require("./architect/polyfills/workers/#{type}_worker_polyfill")

# Architect
class Architect
  constructor: ({ workersPath, workersSuffix, threads } = {}) ->
    @jobs = {}
    @workers = {}
    @workersPath = if workersPath then "/#{workersPath.replace(/^\//, '')}" else '/workers'
    @workersSuffix = workersSuffix || '_worker.min.js'

  spawnWorker: (type) ->
    return this.getPolyfillForType(type) unless this.workersAreSupported()
    new Worker(this.getWorkerPathForType(type))

  getWorkerPathForType: (type) ->
    "#{@workersPath}/#{type}#{@workersSuffix}"

  getPolyfillForType: (type) ->
    klass = Polyfills[type]

    unless klass
      throw new Error("#{type} is not a valid type")

    new klass

  workersAreSupported: (scope = window) ->
    @workersSupported ?= 'Worker' of scope

  requireParams: (requiredParams, params = {}) ->
    missing = []
    requiredParams = [requiredParams] unless Array.isArray(requiredParams)

    for requiredParam in requiredParams when !(requiredParam of params)
      if (splits = requiredParam.split(/\s?\|\|\s?/)).length > 1
        optional = []
        for split in splits when (split of params)
          optional.push(split)

        missing.push(requiredParam) unless optional.length
      else
        missing.push(requiredParam)

    return unless missing.length
    throw new Error("Missing required “#{missing.join(', ')}” parameter#{if missing.length > 1 then 's' else ''}")

  getJobId: ->
    @jobId ||= 1
    @jobId++

  # Workers
  work: ({ data, type, path } = {}) ->
    this.requireParams('type || path', arguments[0])

    new Promise (resolve, reject) =>
      id = this.getJobId()
      @jobs[id] = { id: id, resolve: resolve, reject: reject }

      unless worker = @workers[type || path]
        worker = if type then this.spawnWorker(type) else new Worker(path)
        worker.addEventListener('message', this.handleMessage)
        @workers[type || path] = worker

      worker.postMessage(id: id, args: data)

  handleMessage: (e) =>
    { id, resolve, reject } = e.data

    promise = @jobs[id]
    delete @jobs[id]

    if 'resolve' of e.data
      promise.resolve(resolve)
    else
      promise.reject(new Error(reject))

  jsonp: (data = {}) ->
    if typeof data is 'string'
      data = { url: data }

    this.requireParams('url', data)
    this.work(data: data, type: 'jsonp')

  ajax: (options = {}) ->
    this.requireParams('url', options)
    { success, error } = options

    # Clone options without callback functions
    opts = JSON.parse(JSON.stringify(options))
    delete opts.success
    delete opts.error

    # Support both ajax opts.success & promise resolving
    new Promise (resolve, reject) =>
      this.work(data: opts, type: 'ajax')
        .then (data) -> resolve(data); success?(data)
        .catch (err) -> reject(err); error?(err)

  custom: ({ path, data, fallback } = {}) ->
    this.requireParams('path', arguments[0])

    new Promise (resolve, reject) =>
      if this.workersAreSupported()
        this.work(data: data, path: path).then(resolve)
      else if fallback
        resolve(fallback(data))
      else
        reject("Workers not supported and fallback not provided for #{path}")

# Export
module.exports = Architect
