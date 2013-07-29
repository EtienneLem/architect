module Architect
  class Engine < ::Rails::Engine
    initializer 'architect.assets.precompile' do |app|
      app.config.assets.precompile << 'workers/*'
    end
  end
end
