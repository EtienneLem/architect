class @Architect.JSONPWorker extends @Architect.Worker

  constructor: ->
    super()
    window.jsonpID ||= 0

  postMessage: (url) ->
    tmpScript = document.createElement('script')

    callbackName = 'architect_jsonp' + (++window.jsonpID)
    window[callbackName] = (data) =>
      delete window[callbackName]
      document.head.removeChild(tmpScript)

      this.handleRequest(data)

    tmpScript.src = this.appendQuery(url, "callback=#{callbackName}")
    document.head.appendChild(tmpScript)

  appendQuery: (url, query) ->
    (url + '&' + query).replace(/[&?]{1,2}/, '?')
