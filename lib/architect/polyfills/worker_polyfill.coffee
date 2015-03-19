class WorkerPolyfill
  constructor: ->
    @callbacks = {}
    @callbacksQueue = {}

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

  postMessage: -> # Implemented in child polyfills
  terminate: -> # This is meant to be empty

# Export
module.exports = WorkerPolyfill
