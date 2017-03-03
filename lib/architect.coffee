# Architect
class Architect
  constructor: () ->
    @jobs = {}
    @workers = {}

  spawnWorker: ({ type, data, fn } = {}) ->
    # Known type
    try
      work = require("./workers/#{type}")

    # Unkown type
    catch e
      # Custom
      if fn
        work = require('./workers/custom')

      else
        throw new Error("Unkown worker type “#{type}” and no fn provided")

    # Native worker
    if this.workersAreSupported()
      fnRaw = if fn then "work = #{fn.toString()};" else ''
      workerRaw = "(#{work.toString()})()"

      blob = new Blob([fnRaw, workerRaw])
      blobURL = window.URL.createObjectURL(blob)

      new Worker(blobURL)

    # Polyfill
    else
      WorkerPolyfill = require('./workers/polyfill')
      new WorkerPolyfill(work, fn)

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
  work: ({ type, data, fn } = {}) ->
    this.requireParams('type', arguments[0])

    new Promise (resolve, reject) =>
      jobId = this.getJobId()
      @jobs[jobId] = { id: jobId, resolve: resolve, reject: reject }

      unless worker = @workers[type]
        worker = this.spawnWorker({ type, data, fn })
        worker.addEventListener('message', this.handleMessage)
        @workers[type] = worker

      worker.postMessage(id: jobId, args: data)

  handleMessage: (e) =>
    { id, resolve, reject } = e.data

    promise = @jobs[id]
    delete @jobs[id]

    if 'resolve' of e.data
      promise.resolve(resolve)
    else
      promise.reject(reject)

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

# Export
module.exports = Architect
