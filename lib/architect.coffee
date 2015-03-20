# Requires
Polyfills = {}
for type in ['ajax', 'jsonp']
  Polyfills[type] = require("./architect/polyfills/workers/#{type}_worker_polyfill.coffee")

# Architect
class Architect
  constructor: ({ workersPath, workersSuffix } = {}) ->
    @jobs = {}
    @workersPath = workersPath || '/workers'
    @workersSuffix = workersSuffix || '_worker.min.js'

  spawnWorker: (type) ->
    return this.getPolyfillForType(type) unless this.workersAreSupported()
    new Worker(this.getWorkersPathForType(type))

  getWorkersPathForType: (type) ->
    "#{@workersPath}/#{type}#{@workersSuffix}"

  getPolyfillForType: (type) ->
    new Polyfills[type]

  workersAreSupported: ->
    @workersSupported ?= !!window.Worker

  # Short-lived workers
  work: ({ data, type, worker }) ->
    new Promise (resolve) =>
      worker ||= this.spawnWorker(type)
      worker.postMessage(data)
      worker.addEventListener 'message', (e) ->
        worker.terminate()
        resolve(e.data)

  jsonp: (data) ->
    if typeof data is 'string'
      data = { url: data }

    this.work(data: data, type: 'jsonp')

  ajax: (options) ->
    { success, error } = options
    delete options.success
    delete options.error

    new Promise (resolve, reject) =>
      this.work(data: options, type: 'ajax').then (data) ->
        if 'success' of data
          resolve(data.success)
          success?(data.success)
        else if 'error' of data
          reject(data.error)
          error?(data.error)

  # Custom workers
  custom: ({ path, data, fallback }) ->
    new Promise (resolve, reject) =>
      if this.workersAreSupported()
        worker = new Worker(path)
        this.work(data: data, worker: worker).then(resolve)
      else if fallback
        resolve(fallback(data))
      else
        reject("Workers not supported and fallback not provided for #{path}")

# Export
module.exports = Architect
