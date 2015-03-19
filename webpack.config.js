var webpack = require('webpack')

// Examples
var examples = {
  cache: true,
  watch: true,

  entry: {
    'short_lived_workers_example': ['./examples/short_lived_workers/app.js'],
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
    }
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

  plugins: [
    new webpack.optimize.UglifyJsPlugin({
      compressor: { warnings: false }
    })
  ],
}

// Export
module.exports = {
  build: [examples, workers(false)],
  dist:  [architect, workers(true)],
}
