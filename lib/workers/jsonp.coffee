globalScope = self

module.exports = ->
  appendQuery = (url, query) ->
    (url + '&' + query).replace(/[&?]{1,2}/, '?')

  this.onmessage = (e) ->
    { id, args } = e.data
    { url, callbackAttribute, callbackFnName } = args

    if callbackAttribute is undefined
      callbackAttribute = 'callback'

    if callbackFnName is undefined
      callbackFnName = "handleRequest_#{id}"

    request = if callbackAttribute then appendQuery(url, "#{callbackAttribute}=#{callbackFnName}") else url

    # globalScope is defined when in main thread
    # but undefined in WebWorker
    if typeof globalScope is 'undefined'
      globalScope = self

    globalScope[callbackFnName] = =>
      delete globalScope[callbackFnName]
      this.removeScripts?(request)

      args = [].slice.call(arguments)
      args = if args.length > 1 then args else args[0]

      this.postMessage(id: id, resolve: args)

    try
      this.importScripts(request)
    catch err
      this.postMessage
        id: id
        reject:
          message: err.message
          code: err.code
          name: err.name
