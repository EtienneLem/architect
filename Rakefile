$:.unshift File.join(File.dirname(__FILE__), *%w[lib])
require 'tasks/task_helpers'

# Rubygems
require 'bundler'
Bundler::GemHelper.install_tasks

# Dependencies
require 'uglifier'
require 'architect'
require 'sprockets'

# Tasks
desc 'Merge, compiles and minify CoffeeScript files'
task :compile do
  @environment = Sprockets::Environment.new
  @environment.append_path 'app/assets/javascripts'
  @environment.js_compressor = Uglifier.new(mangle: true)

  compile('architect.js')
  compile('workers/proxy_worker.js')
  compile('workers/ajax_worker.js')
  compile('workers/jsonp_worker.js')
end

desc 'Run tests'
task :test do
  puts `phantomjs test/runner.js test/index.html`
end

task :default => :compile

def compile(file)
  minjs = @environment[file].to_s
  out = "static/#{file.sub('.js', '.min.js')}"

  File.open(out, 'w') { |f| f.write(copyright + minjs + "\n") }
  success "Compiled #{out}"
end

def copyright
  @copyright ||= <<-EOS
/*
* Architect v#{Architect::VERSION}
* http://architectjs.org
*
* Copyright 2013, Etienne Lemay http://heliom.ca
* Released under the MIT license
*
* Date: #{Time.now}
*/
EOS
end
