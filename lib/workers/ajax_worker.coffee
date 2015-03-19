handleSuccess = (result) -> postMessage(success: result)
handleError = (xhr, dataType) ->
  # Returning xhr directly throws DataCloneError
  result = {}
  result[key] = xhr[key] for key in [
    'response', 'responseType', 'responseText', 'responseXML', 'responseURL'
    'status', 'statusText'
    'withCredentials'
    'readyState'
    'timeout'
  ]

  # Parse response if dataType is json
  try
    if dataType is 'json'
      response = result['response']
      result['response'] = if /^\s*$/.test(response) then null else JSON.parse(response)
  catch error

  postMessage(error: result)

addEventListener 'message', (e) ->
  { type, url, data, dataType, contentType, headers } = e.data

  type ||= 'GET'

  headers ||= {}
  headers['X-Requested-With'] = 'XMLHttpRequest'

  if contentType isnt false
    headers['Content-Type'] = contentType || 'application/x-www-form-urlencoded'

  xhr = new XMLHttpRequest
  xhr.open(type, url)
  xhr.setRequestHeader(headerName, headerValue) for headerName, headerValue of headers

  xhr.onreadystatechange = (e) ->
    return unless xhr.readyState is 4

    # Success
    if (xhr.status >= 200 && xhr.status < 300) || xhr.status == 304
      result = xhr.responseText

      try
        if dataType is 'script'
          `(1,eval)(result)`
        else if dataType is 'xml'
          result = xhr.responseXML
        else if dataType is 'json'
          result = if /^\s*$/.test(result) then null else JSON.parse(result)
      catch error

      return handleError(xhr, dataType) if error
      handleSuccess(result)

    # Error
    else
      handleError(xhr, dataType)

  xhr.send(data)
