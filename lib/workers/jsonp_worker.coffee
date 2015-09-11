appendQuery = (url, query) ->
  (url + '&' + query).replace(/[&?]{1,2}/, '?')

addEventListener 'message', (e) ->
  { id, args } = e.data
  { url, callbackAttribute, callbackFnName } = args

  if callbackAttribute is undefined
    callbackAttribute = 'callback'

  if callbackFnName is undefined
    callbackFnName = 'handleRequest'

  self[callbackFnName] = (args...) ->
    args = if args.length > 1 then args else args[0]
    postMessage(id: id, resolve: args)

  request = if callbackAttribute then appendQuery(url, "#{callbackAttribute}=#{callbackFnName}") else url

  try
    importScripts(request)
  catch err
    postMessage
      id: id
      reject:
        message: err.message
        code: err.code
        name: err.name
