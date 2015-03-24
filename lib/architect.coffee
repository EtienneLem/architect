# Requires
Polyfills = {}
for type in ['ajax', 'jsonp']
  Polyfills[type] = require("./architect/polyfills/workers/#{type}_worker_polyfill.coffee")

# Architect
class Architect
  constructor: ({ workersPath, workersSuffix } = {}) ->
    @jobs = {}
    @workersPath = if workersPath then "/#{workersPath.replace(/^\//, '')}" else '/workers'
    @workersSuffix = if workersSuffix then "#{workersSuffix.replace(/\.js$/, '')}.js" else '_worker.min.js'

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

  # Short-lived workers
  work: ({ data, type, worker }) ->
    new Promise (resolve) =>
      worker ||= this.spawnWorker(type)
      worker.postMessage(data)
      worker.addEventListener 'message', (e) ->
        worker.terminate()
        resolve(e.data)

  jsonp: (data = {}) ->
    if typeof data is 'string'
      data = { url: data }

    throw new Error("Missing required “url” parameter") unless 'url' of data
    this.work(data: data, type: 'jsonp')

  ajax: (options = {}) ->
    throw new Error("Missing required “url” parameter") unless 'url' of options
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
