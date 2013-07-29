<p align="center">
  <a href="https://github.com/EtienneLem/architect">
    <img src="https://f.cloud.github.com/assets/436043/856991/59ff07ce-f547-11e2-9a89-74501d0878c3.png">
  </a>
</p>

<p align="center">
  <strong>Architect</strong> is a JavaScript library built on top of <a href="http://www.whatwg.org/specs/web-apps/current-work/multipage/workers.html">Web Workers</a>.<br>
  He will manage and polyfill them workers so you don’t have to.
</p>

## Methods
### proxy
Returns anything it receives in a background process. Useful when dealing with heavy DOM manipulation (i.e. Infinite scroll). It greatly improves initial page load speed, especially on mobiles.

```js
images = ['foo.png', 'bar.png', 'twiz.png', 'foozle.png', 'barzle.png', 'twizle.png']
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

## Setup
### Rails
1. Add `gem 'architect'` to your Gemfile.
2. Add `//= require architect` to your JavaScript manifest file (usually found at `app/assets/javascripts/application.js`).
3. Restart your server and you'll have access to your very own Architect!

### Other
You’ll need to serve the [worker files](/static/workers) at `/architect` (i.e. `http://foo.com/architect/proxy_worker.min.js`) and manually include [architect.min.js](/static/architect.min.js) to your HTML pages.

## Todo
- A way to reuse the same worker (and stop it) [[See #1](https://github.com/EtienneLem/architect/issues/1)]
- Support Shared Workers [[See #3](https://github.com/EtienneLem/architect/issues/3)]
