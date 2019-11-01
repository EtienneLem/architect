{ Architect, simple, expect, helpers } = require('./spec_helper')
{ delay, callbackSequence } = helpers

describe 'Architect', ->
  beforeEach ->
    @architect = new Architect
      workersPath: '/build/workers'
      workersSuffix: '_worker.js'

    simple.mock window.Worker.prototype, 'postMessage', (data) ->
      setTimeout =>
        event = new Event('message')
        event.data = { id: data.id, resolve: data.args }
        this.dispatchEvent(event)
      , 0

  it 'has defaults', ->
    architect = new Architect
    expect(architect.workersPath).to.eq('/workers')
    expect(architect.workersSuffix).to.eq('_worker.min.js')

  describe '#getWorkerPathForType',  ->
    it 'returns a relative worker path', ->
      architect = new Architect
      expect(architect.getWorkerPathForType('foo')).to.eq('/workers/foo_worker.min.js')

      architect = new Architect(workersPath: '/specs')
      expect(architect.getWorkerPathForType('foo')).to.eq('/specs/foo_worker.min.js')

      architect = new Architect(workersPath: 'specs')
      expect(architect.getWorkerPathForType('foo')).to.eq('/specs/foo_worker.min.js')

      architect = new Architect(workersSuffix: 'specs.js')
      expect(architect.getWorkerPathForType('foo')).to.eq('/workers/foospecs.js')

  describe '#getPolyfillForType',  ->
    it 'returns a worker polyfill', ->
      architect = new Architect
      expect(architect.getPolyfillForType('ajax').constructor.name).to.eq('AjaxWorkerPolyfill')
      expect(architect.getPolyfillForType('jsonp').constructor.name).to.eq('JSONPWorkerPolyfill')
      expect(-> architect.getPolyfillForType('specs')).to.throw('specs is not a valid type')

  describe '#workersAreSupported',  ->
    beforeEach -> @architect = new Architect

    describe 'when workers are supported', ->
      it 'returns true', -> expect(@architect.workersAreSupported({ Worker: true })).to.be.true

    describe 'when workers are not supported', ->
      it 'returns false', -> expect(@architect.workersAreSupported({})).to.be.false

  describe '#spawnWorker', ->
    describe 'when workers are supported', ->
      it 'returns a WebWorker', ->
        worker = @architect.spawnWorker('ajax')
        expect(worker).to.be.an.instanceof(window.Worker)

    describe 'when workers are not supported', ->
      beforeEach -> simple.mock(@architect, 'workersAreSupported', -> false)
      it 'returns a WorkerPolyfill', ->
        worker = @architect.spawnWorker('ajax')
        expect(worker.constructor.name).to.eq('AjaxWorkerPolyfill')

  describe '#requireParams', ->
    it 'throws an error when parameter is missing', ->
      expect(=> @architect.requireParams('foo', {})).to.throw('Missing required “foo” parameter')
      expect(=> @architect.requireParams('foo', { foo: 'bar' })).not.to.throw()

    it 'handles multiple parameters', ->
      expect(=> @architect.requireParams(['foo', 'bar'], {})).to.throw('Missing required “foo, bar” parameters')
      expect(=> @architect.requireParams(['foo', 'bar'], { foo: 'bar' })).to.throw('Missing required “bar” parameter')
      expect(=> @architect.requireParams(['foo', 'bar'], { foo: 'bar', bar: 'foo' })).not.to.throw()

    it 'handles “||” operator', ->
      expect(=> @architect.requireParams('foo || bar', {})).to.throw('Missing required “foo || bar” parameter')
      expect(=> @architect.requireParams('foo||bar', { foo: 'bar' })).not.to.throw()
      expect(=> @architect.requireParams('foo ||bar', { bar: 'foo' })).not.to.throw()
      expect(=> @architect.requireParams(['foo || bar', 'twiz'], { bar: 'foo' })).to.throw('Missing required “twiz” parameter')
      expect(=> @architect.requireParams(['foo || bar', 'twiz'], {})).to.throw('Missing required “foo || bar, twiz” parameter')

  describe 'Workers', ->
    describe '#work', ->
      it 'returns a promise', ->
        promise = @architect.work(type: 'fake', data: { foo: 'bar' })
        expect(promise).to.be.an.instanceof(window.Promise)

        result = @architect.work(type: 'fake', data: { foo: 'bar' })
        expect(result).to.eventually.deep.equal(foo: 'bar')

      it 'stores current workers', ->
        expect(Object.keys(@architect.workers).length).to.equal(0)
        @architect.work(type: 'fake', data: { foo: 'bar' })

        expect(Object.keys(@architect.workers).length).to.equal(1)
        expect(@architect.workers.fake).to.be.defined

      it 'spawns a worker when working for the first time', ->
        simple.mock(@architect, 'spawnWorker')
        @architect.work(type: 'fake', data: { foo: 'bar' })

        expect(@architect.spawnWorker.calls.length).to.equal(1)

      it 'reuses existing workers', (done) ->
        simple.mock(@architect, 'spawnWorker')
        simple.mock(@architect, 'handleMessage')

        @architect.work(type: 'fake', data: { foo: 'bar' })
        @architect.work(type: 'fake', data: { foo: 'bar' })

        delay 0, done, =>
          expect(@architect.spawnWorker.calls.length).to.equal(1)
          expect(@architect.handleMessage.calls.length).to.equal(2)

      it 'stores current jobs', ->
        expect(Object.keys(@architect.jobs).length).to.equal(0)

        @architect.work(type: 'fake', data: { foo: 'bar' })
        @architect.work(type: 'fake', data: { foo: 'bar' })
        @architect.work(type: 'fake', data: { foo: 'bar' })

        expect(Object.keys(@architect.jobs).length).to.equal(3)
        for i in [1..3]
          expect(@architect.jobs).to.have.deep.property("#{i}.id", i)
          expect(@architect.jobs).to.have.deep.property("#{i}.resolve")
          expect(@architect.jobs).to.have.deep.property("#{i}.reject")

    describe 'aliases', ->
      beforeEach ->
        simple.mock @architect, 'work', ->
          new Promise (resolve) -> resolve({})

      describe '#ajax', ->
        it 'is an alias for Architect#work(type: "ajax")', ->
          @architect.ajax(url: '')
          expect(@architect.work.calls.length).to.eq(1)
          expect(@architect.work.calls[0].args[0].type).to.eq('ajax')

        it 'requires url: parameter', ->
          expect(=> @architect.ajax()).to.throw('Missing required “url” parameter')
          expect(=> @architect.ajax(url: '')).not.to.throw()

        it 'supports $.ajax-style success/error options', (done) ->
          simple.mock @architect, 'work', callbackSequence [
            => new Promise (resolve) => resolve
              id: 1, resolve: { foo: 'bar' }
            => new Promise (resolve, reject) => reject
              id: 2, reject: { bar: 'foo' }
          ]

          options =
            url: ''
            success: simple.spy()
            error: simple.spy()

          @architect.ajax(options)
          delay 0, =>
            expect(options.success.calls.length).to.eq(1)
            expect(options.error.calls.length).to.eq(0)

            @architect.ajax(options).catch(->)
            delay 0, done, ->
              expect(options.success.calls.length).to.eq(1)
              expect(options.error.calls.length).to.eq(1)

      describe '#jsonp', ->
        it 'is an alias for Architect#work(type: "jsonp")', ->
          @architect.jsonp(url: '')
          expect(@architect.work.calls.length).to.eq(1)
          expect(@architect.work.calls[0].args[0].type).to.eq('jsonp')

        it 'requires url: parameter', ->
          expect(=> @architect.jsonp()).to.throw('Missing required “url” parameter')
          expect(=> @architect.jsonp(url: '')).not.to.throw()

  describe 'Custom workers', ->
    describe '#custom', ->
      beforeEach ->
        simple.mock @architect, 'work', ->
          new Promise (resolve) -> resolve({})

      it 'requires path: parameter', ->
        expect(=> @architect.custom()).to.throw('Missing required “path” parameter')
        expect(=> @architect.custom(path: '/build/workers/fake_worker.js')).not.to.throw()

      describe 'when workers are supported', ->
        it 'is an alias for Architect#work(path:)', ->
          @architect.custom(path: '/build/workers/fake_worker.js', data: { foo: 'bar' })
          expect(@architect.work.calls.length).to.eq(1)
          expect(@architect.work.calls[0].args[0].data).to.deep.equal(foo: 'bar')
          expect(@architect.work.calls[0].args[0].path).to.equal('/build/workers/fake_worker.js')

      describe 'when workers are not supported', ->
        beforeEach -> simple.mock(@architect, 'workersAreSupported', -> false)

        describe 'when a fallback is provided', ->
          beforeEach ->
            @fallback = simple.spy((data) -> data.fake = true; data)

          it 'uses the fallback in the main thread', ->
            result = @architect.custom(path: '/build/workers/fake_worker.js', data: { foo: 'bar' }, fallback: @fallback)
            expect(@fallback.calls.length).to.equal(1)
            expect(result).to.eventually.deep.equal(foo: 'bar', fake: true)

        describe 'when a fallback is not provided', ->
          it 'rejects the promise', ->
            result = @architect.custom(path: '/build/workers/fake_worker.js', data: { foo: 'bar' })
            expect(result).to.be.rejectedWith('Workers not supported and fallback not provided for /build/workers/fake_worker.js')
