class @Architect.ProxyWorker extends @Architect.Worker

  postMessage: (data) ->
    this.handleRequest(data)
