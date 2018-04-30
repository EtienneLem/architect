var Architect = require('architect')
architect = new Architect()

//
// JSONP
//
// architect.jsonp({ url: 'https://api.github.com/users/etiennelem' })
//   .then(function(e) { console.log('JSONP:', e) })
//
// architect.jsonp({ url: 'https://api.github.com/users/etiennelem' }, { usePolyfill: true })
//   .then(function(e) { console.log('JSONP (Polyfill):', e) })
//
// architect.jsonp({ url: 'nope' })
//   .then(function(e) { console.log('JSONP (Shouldn’t log):', e) })
//   .catch(function(e) { console.log('JSONP Error:', e) })
//
// architect.jsonp({ url: 'nope' }, { usePolyfill: true })
//   .then(function(e) { console.log('JSONP (Shouldn’t log):', e) })
//   .catch(function(e) { console.log('JSONP Error (Polyfill):', e) })
//
// architect.jsonp({ url: 'http://foo' }, { usePolyfill: true })
//   .then(function(e) { console.log('JSONP (Shouldn’t log):', e) })
//   .catch(function(e) { console.log('JSONP Error (Polyfill):', e) })

//
// Ajax
//
// architect.ajax({ url: 'https://api.github.com/users/_etiennelem', dataType: 'json' })
//   .then(function(e) { console.log('AJAX:', e) })
//   .catch(function(e) { console.log('AJAX ERROR:', e.response.message) })

architect.ajax({ url: 'https://httpbin.org/get', dataType: 'json', timeout: 16 })
  .then(console.log)
  .catch(console.warn)

//
// Custom
//
// architect.work({
//   type: 'foozle',
//   data: 'foo',
//   fn: function(data) {
//     return (data + 'zle').toUpperCase()
//   },
// }).then(function(e) { console.log('CUSTOM:', e) })
//
// architect.work({
//   type: 'bar',
//   data: 'foo',
//   fn: `function(data) {
//     return (data + 'bar')
//   }`,
// }).then(function(e) { console.log('CUSTOM (STRING FN):', e) })
//
// architect.work({
//   type: 'promise',
//   data: 'foo',
//   fn: function(data) {
//     return new Promise(function(resolve, reject) {
//       setTimeout(function() {
//         resolve(data + 'zle')
//       }, 1000)
//     })
//   },
// }).then(function(e) { console.log('CUSTOM (Promise):', e) })

//
// $.ajax style
//
// architect.ajax({
//   url: 'https://api.github.com/users/etiennelem',
//   dataType: 'json',
//   success: function(e) { console.log('AJAX:', e) }
// })
