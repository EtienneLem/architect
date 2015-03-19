var Architect = require('architect')

architect = new Architect({
  workersPath: '/build/workers',
  workersSuffix: '_worker.js',
})

// JSONP
architect.jsonp({
  url: 'https://api.github.com/users/etiennelem'
}).then(function(e) { console.log('JSONP:', e) })

// Ajax
architect.ajax({ url: 'https://api.github.com/users/_etiennelem', dataType: 'json' })
  .then(function(e) { console.log('AJAX:', e) })
  .catch(function(e) { console.log('AJAX ERROR:', e) })

// $.ajax style
architect.ajax({
  url: 'https://api.github.com/users/etiennelem',
  dataType: 'json',
  success: function(e) { console.log('AJAX:', e) }
})
