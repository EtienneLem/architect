class @Architect.AjaxWorker extends @Architect.Worker
  handleSuccess: (result) -> this.handleRequest(success: result)
  handleError:   (xhr) -> this.handleRequest(error: xhr)

  postMessage: (opts) ->
    { type, url, data, dataType, contentType, headers } = e.data

    type ||= 'GET'

    headers ||= {}
    headers['X-Requested-With'] = 'XMLHttpRequest'

    if contentType isnt false
      headers['Content-Type'] = contentType || 'application/x-www-form-urlencoded'

    xhr = new XMLHttpRequest
    xhr.open(type, url)
    xhr.setRequestHeader(headerName, headerValue) for headerName, headerValue of headers

    xhr.onreadystatechange = (e) =>
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

        return this.handleError(xhr) if error
        this.handleSuccess(result)

      # Error
      else
        this.handleError(xhr)

    xhr.send(data)
