require './lib/architect/version'

Gem::Specification.new do |s|
  s.name        = 'architect'
  s.version     = Architect::VERSION
  s.authors     = ['Etienne Lemay']
  s.email       = ['etienne@heliom.ca']
  s.homepage    = 'http://architectjs.org'
  s.summary     = 'Your web workers’ supervisor'
  s.description = 'Architect is a JavaScript library built on top of Web Workers that will handle and polyfill HTML Web Workers.'
  s.license     = 'MIT'

  s.files      = `git ls-files`.split($/)
  s.test_files = s.files.grep(%r{^(test)/})

  s.add_dependency 'coffee-rails'

  s.add_development_dependency 'rake'
  s.add_development_dependency 'uglifier'
  s.add_development_dependency 'sprockets'
end
