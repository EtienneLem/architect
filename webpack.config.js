var webpack = require('webpack')

// Examples
var examples_and_specs = {
  cache: true,
  watch: true,

  entry: {
    'specs': ['mocha!./specs'],
    'workers/fake_worker': ['./specs/fixtures/workers/fake_worker.coffee'],

    'short_lived_workers_example': ['./examples/short_lived_workers/app.js'],
    'custom_workers_example': ['./examples/custom_workers/app.js'],
    'workers/custom_worker': ['./examples/custom_workers/workers/custom_worker.js'],
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

// Workers
var workers = function(dist) {
  var configs = {
    cache: true,
    watch: true,

    entry: {
      'workers/ajax_worker': ['./lib/workers/ajax_worker.coffee'],
      'workers/jsonp_worker': ['./lib/workers/jsonp_worker.coffee'],
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
      extensions: ['', '.js', '.coffee']
    },
  }

  if (dist) {
    configs.output.filename = '[name].min.js'
    configs.watch = false
    configs.plugins = architect.plugins
  }

  return configs
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
    extensions: ['', '.js', '.coffee']
  },

  plugins: [
    new webpack.optimize.UglifyJsPlugin({
      compressor: { warnings: false }
    })
  ],
}

// Export
module.exports = {
  build: [workers(false), examples_and_specs],
  dist:  [workers(true),  architect],
}
