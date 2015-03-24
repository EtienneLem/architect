{ Architect, simple, expect, helpers } = require('./spec_helper.coffee')

describe 'Architect', ->
  beforeEach ->
    @architect = new Architect
      workersPath: '/build/workers'
      workersSuffix: '_worker.js'

  describe '#getWorkersPathForType',  ->
    it 'returns a relative worker path', ->
      architect = new Architect
      expect(architect.getWorkersPathForType('foo')).to.eq('/workers/foo_worker.min.js')

      architect = new Architect(workersPath: '/specs')
      expect(architect.getWorkersPathForType('foo')).to.eq('/specs/foo_worker.min.js')

      architect = new Architect(workersPath: 'specs')
      expect(architect.getWorkersPathForType('foo')).to.eq('/specs/foo_worker.min.js')

      architect = new Architect(workersSuffix: 'specs.js')
      expect(architect.getWorkersPathForType('foo')).to.eq('/workers/foospecs.js')

      architect = new Architect(workersSuffix: '_specs.bar')
      expect(architect.getWorkersPathForType('foo')).to.eq('/workers/foo_specs.bar.js')

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

  describe 'Short-lived workers', ->
    describe '#work', ->
      it 'returns a promise', ->
        promise = @architect.work(type: 'fake', data: { foo: 'bar' })
        expect(promise).to.be.an.instanceof(window.Promise)

        result = @architect.work(type: 'fake', data: { foo: 'bar' })
        expect(result).to.eventually.deep.equal(foo: 'bar')

      it 'can receive and work on an existing worker', ->
        worker = @architect.spawnWorker('fake')
        simple.mock(worker, 'postMessage')

        @architect.work(worker: worker)
        expect(worker.postMessage.calls.length).to.eq(1)

      it 'terminates a worker when done', (done) ->
        worker = @architect.spawnWorker('fake')
        simple.mock(worker, 'terminate')

        @architect.work(worker: worker).then =>
          expect(worker.terminate.calls.length).to.eq(1)
          done()

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
          simple.mock @architect, 'work', helpers.callbackSequence [
            => new Promise (resolve) => resolve
              success: { foo: 'bar' }
            => new Promise (resolve) => resolve
              error: { bar: 'foo' }
          ]

          options =
            url: ''
            success: simple.spy()
            error: simple.spy()

          @architect.ajax(options)
          helpers.delay 0, =>
            expect(options.success.calls.length).to.eq(1)
            expect(options.error.calls.length).to.eq(0)

            @architect.ajax(options).catch(->)
            helpers.delay 0, done, ->
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
      describe 'when workers are supported', ->
        beforeEach ->
          simple.mock @architect, 'work', ->
            new Promise (resolve) -> resolve({})

        it 'is an alias for Architect#work(worker:)', ->
          @architect.custom(path: '/build/workers/fake_worker.js', data: { foo: 'bar' })
          expect(@architect.work.calls.length).to.eq(1)
          expect(@architect.work.calls[0].args[0].data).to.deep.equal(foo: 'bar')
          expect(@architect.work.calls[0].args[0].worker).to.be.an.instanceof(window.Worker)

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
