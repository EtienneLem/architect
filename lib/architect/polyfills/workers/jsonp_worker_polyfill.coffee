WorkerPolyfill = require('../worker_polyfill.coffee')

class JSONPWorkerPolyfill extends WorkerPolyfill
  postMessage: (data) ->
    { url, callbackAttribute, callbackFnName } = data

    if callbackAttribute is undefined
      callbackAttribute = 'callback'

    if callbackFnName is undefined
      @jsonpID ||= 0
      callbackFnName = 'architect_jsonp' + (++@jsonpID)

    window[callbackFnName] = (args...) =>
      delete window[callbackFnName]
      this.removeScript()
      args = if args.length > 1 then args else args[0]
      this.handleRequest(args)

    request = if callbackAttribute then this.appendQuery(url, "#{callbackAttribute}=#{callbackFnName}") else url
    this.addScript(request)

  addScript: (request) ->
    @tmpScript = document.createElement('script')
    @tmpScript.src = request

    document.head.appendChild(@tmpScript)

  removeScript: ->
    document.head.removeChild(@tmpScript)

  appendQuery: (url, query) ->
    (url + '&' + query).replace(/[&?]{1,2}/, '?')

# Export
module.exports = JSONPWorkerPolyfill
