class WorkerPolyfill
  constructor: (work, @fn) ->
    @jobs = {}
    @scripts = {}
    @callbacks = {}
    @callbacksQueue = {}

    work.call(this)

  addEventListener: (type, callback) ->
    @callbacks[type] = callback

    return unless data = @callbacksQueue[type]
    delete @callbacksQueue[type]

    this.dispatch(type, data)

  dispatch: (type, data) ->
    if @callbacks[type]
      @callbacks[type]({data: data})
    else
      @callbacksQueue[type] = data

  handleRequest: (data) ->
    this.dispatch('message', data)

  postMessage: (e) ->
    if @jobs[e.id]
      this.dispatch('message', e)
    else
      @jobs[e.id] = e
      this.onmessage(data: e)

  importScripts: (request) ->
    script = document.createElement('script')
    script.src = request

    document.head.appendChild(script)
    @scripts[request] = script

  removeScripts: (request) ->
    return unless script = @scripts[request]
    delete @scripts[request]

    document.head.removeChild(script)

  terminate: -> # noop

# Export
module.exports = WorkerPolyfill
