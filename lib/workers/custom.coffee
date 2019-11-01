module.exports = ->
  this.onmessage = (e) =>
    { id, args } = e.data

    # `work` function injected by Architect when in WebWorker
    # `fn` provided by WorkerPolyfill when in main thread
    if this.fn
      if typeof this.fn is 'string'
        this.fn = eval("this._fn = #{this.fn}")

      result = this.fn(args)
    else
      result = work(args)

    if result instanceof Promise
      result
        .then (data) => this.postMessage(id: id, resolve: data)
        .catch (err) => this.postMessage(id: id, reject: err)
    else
      this.postMessage(id: id, resolve: result)
