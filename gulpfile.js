var gulp = require('gulp');
var del = require('del');
var connect = require('gulp-connect');
var webpack = require('gulp-webpack');
var webpackConfig = require('./webpack.config.js');

var port = process.env.PORT || 8080;
var reloadPort = process.env.RELOAD_PORT || 35729;

var webpackFor = function(target) {
  del([target])

  configs = webpackConfig[target]
  if (!Array.isArray(configs)) { configs = [configs] }

  for (var i = 0; i < configs.length; i++) {
    config = configs[i]

    webpack(config)
      .pipe(gulp.dest(target))
  }
}

gulp.task('build', function () {
  webpackFor('build')
});

gulp.task('dist', function() {
  webpackFor('dist')
})

gulp.task('serve', function () {
  connect.server({
    port: port,
    livereload: {
      port: reloadPort
    }
  });
});

gulp.task('reload-js', function () {
  return gulp.src('./build/*.js')
    .pipe(connect.reload());
});

gulp.task('watch', function () {
  gulp.watch(['./build/*.js'], ['reload-js']);
});

gulp.task('default', ['build', 'serve', 'watch']);
