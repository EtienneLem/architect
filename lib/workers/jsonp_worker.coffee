appendQuery = (url, query) ->
  (url + '&' + query).replace(/[&?]{1,2}/, '?')

addEventListener 'message', (e) ->
  { url, callbackAttribute, callbackFnName } = e.data

  if callbackAttribute is undefined
    callbackAttribute = 'callback'

  if callbackFnName is undefined
    callbackFnName = 'handleRequest'

  self[callbackFnName] = (args...) ->
    args = if args.length > 1 then args else args[0]
    postMessage(args)

  request = if callbackAttribute then appendQuery(url, "#{callbackAttribute}=#{callbackFnName}") else url
  importScripts(request)