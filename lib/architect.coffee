# Requires
Polyfills = {}
for type in ['ajax', 'jsonp']
  Polyfills[type] = require("./architect/polyfills/workers/#{type}_worker_polyfill.coffee")

# Architect
class Architect
  constructor: ({ workersPath, workersSuffix, threads } = {}) ->
    @jobs = {}
    @queue = []
    @threads = threads || 5
    @workersPath = if workersPath then "/#{workersPath.replace(/^\//, '')}" else '/workers'
    @workersSuffix = workersSuffix || '_worker.min.js'

  spawnWorker: (type) ->
    return this.getPolyfillForType(type) unless this.workersAreSupported()
    new Worker(this.getWorkersPathForType(type))

  getWorkersPathForType: (type) ->
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

  # Short-lived workers
  work: ({ data, type, worker } = {}) ->
    this.requireParams('type || worker', arguments[0])
    jobId = this.getJobId()

    new Promise (resolve) =>
      this.enqueue(jobId).then =>
        @jobs[jobId] = worker ||= this.spawnWorker(type)
        worker.postMessage(data)
        worker.addEventListener 'message', (e) =>
          this.clearJob(jobId)
          worker.terminate()
          resolve(e.data)

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

    new Promise (resolve, reject) =>
      this.work(data: opts, type: 'ajax').then (data) ->
        if 'success' of data
          resolve(data.success)
          success?(data.success)
        else if 'error' of data
          reject(data.error)
          error?(data.error)

  # Custom workers
  custom: ({ path, data, fallback } = {}) ->
    this.requireParams('path', arguments[0])

    new Promise (resolve, reject) =>
      if this.workersAreSupported()
        worker = new Worker(path)
        this.work(data: data, worker: worker).then(resolve)
      else if fallback
        resolve(fallback(data))
      else
        reject("Workers not supported and fallback not provided for #{path}")

  # Threads
  enqueue: (jobId) ->
    new Promise (resolve) =>
      setTimeout =>
        if Object.keys(@jobs).length < @threads
          resolve()
        else
          @queue.push({ resolve: resolve })
      , 0

  clearJob: (jobId) ->
    delete @jobs[jobId]

    return unless @queue.length
    job = @queue.shift()
    job.resolve()

# Export
module.exports = Architect
