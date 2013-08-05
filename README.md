<p align="center">
  <a href="https://github.com/EtienneLem/architect">
    <img src="https://f.cloud.github.com/assets/436043/856991/59ff07ce-f547-11e2-9a89-74501d0878c3.png">
  </a>
</p>

<p align="center">
  <strong>Architect</strong> is a JavaScript library built on top of <a href="http://www.whatwg.org/specs/web-apps/current-work/multipage/workers.html">Web Workers</a>.<br>
  He will manage and polyfill them workers so you don’t have to.
</p>

## Short-lived workers
These will be automatically terminated as soon as the work is done. It will spawn a new worker every time.

### proxy
Returns anything it receives in a background process. Useful when dealing with heavy DOM manipulation (i.e. Infinite scroll). It greatly improves initial page load speed, especially on mobiles.

```js
var images = ['foo.png', 'bar.png', 'twiz.png', 'foozle.png', 'barzle.png', 'twizle.png']
Architect.proxy(images, function(data) {
  console.log(data)
  // => ['foo.png', 'bar.png', 'twiz.png', 'foozle.png', 'barzle.png', 'twizle.png']

  data.forEach(function(image) {
    img = document.createElement('img')
    img.src = image

    document.body.appendChild(img)
  })
})
```

Alias for `Architect.work(data, 'proxy', callback)`.

### ajax
Makes an Ajax request in a background process.

```js
Architect.ajax('/users/1', function(data) {
  console.log(data);
  // => { id: 1, name: 'Foo', email: 'foo@bar.com' }
})
```

Alias for `Architect.work(url, 'ajax', callback)`.

### jsonp
Makes a JSONP request in a background process. **Do not add `?callback=foo` to your URL**, Architect will handle JSONP callbacks himself. See the [request Architect makes](https://api.github.com/users/etiennelem?callback=architect_jsonp).

```js
Architect.jsonp('https://api.github.com/users/etiennelem', function(data) {
  console.log(data);
  // => { meta: { status: 200, … }, data: { login: 'EtienneLem', company: 'Heliom', … } }
})
```

Alias for `Architect.work(url, 'jsonp', callback)`.

## Long-lived workers
These need to be manually terminated when the work is done. The same worker can therefore be reused many times with different data.

### proxyOn
```js
var images, jobName, imagesCount

images = ['foo.png', 'bar.png', 'twiz.png', 'foozle.png', 'barzle.png', 'twizle.png']
jobName = 'appendImages'
imagesCount = 0

images.forEach(function(image) {
  Architect.proxyOn(jobName, image, function(data) {
    imagesCount++

    img = document.createElement('img')
    img.src = data
    document.body.appendChild(img)

    if (imagesCount == images.length) { Architect.endJob(jobName) }
  })
})
```

Alias for `Architect.workOn(jobName, data, 'proxy', callback)`.

### ajaxOn
```js
var totalPages, jobName, queryApi

totalPages = 10
jobName = 'getUsers'

queryApi = function(page) {
  Architect.ajaxOn(jobName, '/users?page=' + page, function(data) {
    // [Add DOM elements, do your thing ;)]

    if (page == totalPages) {
      // Manually terminate the 'getUsers' ajax worker
      Architect.endJob(jobName)
      console.log('Done')
    } else {
      // Reuse the same worker
      queryApi(page + 1)
    }
  })
}

queryApi(1)
```

Alias for `Architect.workOn(jobName, url, 'ajax', callback)`.

### jsonpOn
```js
Architect.jsonpOn('profile', 'https://api.github.com/users/etiennelem', function(data) {
  console.log(data);
  // => { meta: { status: 200, … }, data: { login: 'EtienneLem', company: 'Heliom', … } }

  Architect.endJob('profile')
})
```

Alias for `Architect.workOn(jobName, url, 'jsonp', callback)`.

## Custom workers
You can use Architect with your own workers. Just remember that if you want to be compatible with all the old browsers you need to optionally provide a fallback function that replicates your worker’s work.

### workFrom
```js
// workers/foozle.js
addEventListener('message', function(e) {
  data = (e.data + 'zle').toUpperCase()
  postMessage(data)
})
```

```js
// application.js

// Replicates workers/foozle.js, but in the main thread
var foozleFallback = function(data) {
  return (data + 'zle').toUpperCase()
}

Architect.workFrom('workers/foozle.js', 'foo', foozleFallback, function(data) {
  console.log(data)
  // => FOOZLE
})
```

## Setup
### Rails
1. Add `gem 'architect'` to your Gemfile.
2. Add `//= require architect` to your JavaScript manifest file (usually found at `app/assets/javascripts/application.js`).
3. Restart your server and you'll have access to your very own Architect!

### Other
You’ll need to serve the [worker files](/static/workers) at `/architect` (i.e. `http://foo.com/architect/proxy_worker.min.js`) and manually include [architect.min.js](/static/architect.min.js) to your HTML pages.

#### Custom path
You can also specify any path you want to serve the workers from.

```js
Architect.setupWorkersPath('fake/path')
Architect.proxy('Foo', function(data) {
  // => Uses http://yourdomain.com/fake/path/proxy_worker.min.js
})
```

## Tests
Run the `rake test` task.
