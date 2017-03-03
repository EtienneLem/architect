var webpack = require('webpack')

// Examples
var examples_and_specs = {
  cache: true,
  watch: true,

  entry: {
    'specs': ['mocha!./specs'],
    'workers/fake_worker': ['./specs/fixtures/workers/fake_worker.coffee'],

    'examples': ['./examples/app.js'],
  },

  output: {
    filename: '[name].js'
  },

  module: {
    loaders: [
      { test: /\.coffee$/, loader: 'coffee-loader' },
    ]
  },

  resolve: {
    root: __dirname,
    alias: {
      'architect': 'lib/architect.coffee'
    },
    extensions: ['', '.js', '.coffee']
  },
}

// Architect
var architect = {
  cache: true,

  entry: './lib/architect.coffee',
  output: {
    filename: 'architect.min.js',
    library: 'Architect',
    libraryTarget: 'umd',
  },

  module: {
    loaders: [
      { test: /\.coffee$/, loader: 'coffee-loader' },
    ]
  },

  resolve: {
    extensions: ['', '.coffee']
  },

  plugins: [
    new webpack.optimize.UglifyJsPlugin({
      compressor: { warnings: false }
    })
  ],
}

// Export
module.exports = {
  build: [examples_and_specs],
  dist:  [architect],
}
