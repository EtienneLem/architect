class @Architect.AjaxWorker extends @Architect.Worker

  postMessage: (url) ->
    xhr = new XMLHttpRequest
    xhr.open('GET', url)

    xhr.onreadystatechange = (e) =>
      return unless xhr.readyState is 4 && xhr.status is 200
      this.handleRequest(xhr.responseText)

    xhr.send()
