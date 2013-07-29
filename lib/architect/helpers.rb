module Architect
  def self.worker_path(type)
    worker_filename = "#{type}_worker.js"
    return "architect/#{worker_filename.sub('.js', '.min.js')}" unless defined?(Rails)

    # Cacheable digest path on main domain because of same-origin policy
    File.join(
      Rails.application.config.assets.prefix,
      Rails.application.assets["workers/#{worker_filename}"].digest_path
    )
  end
end
