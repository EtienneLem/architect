WorkerPolyfill = require('../worker_polyfill')

class AjaxWorkerPolyfill extends WorkerPolyfill
  handleSuccess: (id, result) -> this.handleRequest(id: id, resolve: result)
  handleError:   (id, xhr) -> this.handleRequest(id: id, reject: xhr)

  postMessage: (e) ->
    { id, args } = e
    { type, url, data, dataType, contentType, headers } = args

    type ||= 'GET'

    headers ||= {}
    headers['X-Requested-With'] ?= 'XMLHttpRequest'

    if contentType isnt false
      headers['Content-Type'] = contentType || 'application/x-www-form-urlencoded'

    xhr = new XMLHttpRequest
    xhr.open(type, url)
    xhr.withCredentials = args.withCredentials if 'withCredentials' of args
    xhr.setRequestHeader(headerName, headerValue) for headerName, headerValue of headers when headerValue

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

        return this.handleError(id, xhr) if error
        this.handleSuccess(id, result)

      # Error
      else
        this.handleError(id, xhr)

    xhr.send(data)

# Export
module.exports = AjaxWorkerPolyfill
