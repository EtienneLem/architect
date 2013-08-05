// Helpers
var disableWorkers = function() {
  Architect.SUPPORT_WORKER = false
}

var makeSureWorkersAreDisabled = function() {
  ok(Architect.SUPPORT_WORKER === false, 'Workers are disabled')
}

// Default Workers
asyncTest('Proxy Polyfill', function() {
  disableWorkers()
  makeSureWorkersAreDisabled()

  Architect.proxy('Foo', function(data) {
    ok(data === 'Foo')
    start()
  })
})

asyncTest('Ajax Polyfill', function() {
  disableWorkers()
  makeSureWorkersAreDisabled()

  Architect.ajax('https://api.github.com/users/etiennelem', function(data) {
    ok(JSON.parse(data).login === 'EtienneLem')
    start()
  })
})

asyncTest('JSONP Polyfill', function() {
  disableWorkers()
  makeSureWorkersAreDisabled()

  Architect.jsonp('https://api.github.com/users/etiennelem', function(data) {
    ok(data.data.login === 'EtienneLem')
    start()
  })
})

// Custom Workers
asyncTest('Custom Fallback', function() {
  disableWorkers()
  makeSureWorkersAreDisabled()

  var foozleWorkerFallback = function(data) {
    return (data + 'zle_doo').toUpperCase()
  }

  Architect.workFrom('./fixture/foozle_worker.js', 'foo', foozleWorkerFallback, function(data) {
    ok(data === 'FOOZLE_DOO')
    start()
  })
})
