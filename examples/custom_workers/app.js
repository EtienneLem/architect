var Architect = require('architect')

architect = new Architect({
  workersPath: '/build/workers',
  workersSuffix: '_worker.js',
})

architect.custom({
  path: '/build/workers/custom_worker.js',
  data: 'foo',
  fallback: function(data) { return (data + 'zle (fallback)').toUpperCase() }
}).then(function(data) {
  console.log('Custom:', data)
})
