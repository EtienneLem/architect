addEventListener('message', function(e) {
  data = e.data + 'zle'
  postMessage(data.toUpperCase())
})
