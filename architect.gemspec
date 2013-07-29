require './lib/architect/version'

Gem::Specification.new do |s|
  s.name        = 'architect'
  s.version     = Architect::VERSION
  s.authors     = ['Etienne Lemay']
  s.email       = ['etienne@heliom.ca']
  s.homepage    = 'https://github.com/EtienneLem/architect'
  s.summary     = 'Your web workers’ supervisor'
  s.description = 'Architect is a JavaScript library built on top of Web Workers that will handle and polyfill HTML Web Workers.'
  s.license     = 'MIT'

  s.files = Dir['{app,lib,static}/**/*', 'Rakefile', 'MIT-LICENSE', 'README.md', 'CHANGELOG.md']

  s.add_dependency 'coffee-rails'

  s.add_development_dependency 'rake'
  s.add_development_dependency 'uglifier'
  s.add_development_dependency 'sprockets'
end
