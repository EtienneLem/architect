// Config
test('Worker Support', function() {
  ok(Architect.SUPPORT_WORKER === true)
})

test('Custom Workers Path', function() {
  initialWorkerPath = Architect.workersPath

  Architect.setupWorkersPath('fake/path')
  ok(Architect.workersPath === 'fake/path', 'Custom path')

  Architect.setupWorkersPath('./fake/path')
  ok(Architect.workersPath === './fake/path', 'Relative path')

  Architect.setupWorkersPath('fake/path/')
  ok(Architect.workersPath === 'fake/path', 'Removes trailing slash')

  Architect.setupWorkersPath(initialWorkerPath)
})

// Default Workers
asyncTest('Proxy Worker', function() {
  Architect.proxy('Foo', function(data) {
    ok(data === 'Foo')
    start()
  })
})

asyncTest('Ajax Worker', function() {
  Architect.ajax('https://api.github.com/users/etiennelem', function(data) {
    ok(JSON.parse(data).login === 'EtienneLem')
    start()
  })
})

asyncTest('JSONP Worker', function() {
  Architect.jsonp('https://api.github.com/users/etiennelem', function(data) {
    ok(data.data.login === 'EtienneLem')
    start()
  })
})

// Custom Workers
asyncTest('Custom Worker', function() {
  Architect.workFrom('./fixture/foozle_worker.js', 'foo', function(data) {
    ok(data === 'FOOZLE')
    start()
  })
})
