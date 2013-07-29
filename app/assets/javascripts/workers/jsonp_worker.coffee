self.handleRequest = (data) ->
  postMessage(data)

appendQuery = (url, query) ->
  (url + '&' + query).replace(/[&?]{1,2}/, '?')

addEventListener 'message', (e) ->
  url = appendQuery(e.data, 'callback=handleRequest')
  importScripts(url)
