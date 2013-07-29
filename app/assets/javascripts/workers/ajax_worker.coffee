handleRequest = (data) ->
  postMessage(data)

addEventListener 'message', (e) ->
  xhr = new XMLHttpRequest
  xhr.open('GET', e.data)
  xhr.onreadystatechange = (e) ->
    return unless xhr.readyState is 4 && xhr.status is 200
    handleRequest(xhr.responseText)

  xhr.send()
