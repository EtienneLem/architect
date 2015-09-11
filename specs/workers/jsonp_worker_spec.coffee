{ Architect, simple, expect, helpers } = require('../spec_helper')
{ delay, callbackSequence } = helpers

describe.only 'JSONP Worker', ->
  beforeEach ->
    @architect = new Architect
      workersPath: '/build/workers'
      workersSuffix: '_worker.js'

  it 'rejects NetworkError', (done) ->
    @architect.jsonp("https://api.example.com/fake")
      .then -> throw 'It shouldn’t throw'
      .catch (err) =>
        expect(err).to.have.deep.property('code', 19)
        expect(err).to.have.deep.property('name', 'NetworkError')
        done()
