# frozen_string_literal: true

require 'capistrano/setup'
require 'capistrano/deploy'

require 'capistrano/scm/git'
install_plugin Capistrano::SCM::Git

require 'capistrano/rbenv'
require 'capistrano/bundler'
# Builds the stylesheet with Dart Sass (dartsass:build runs before assets:precompile) and digests the assets.
require 'capistrano/rails/assets'
require 'capistrano/rails/migrations'
require 'capistrano/passenger'

# Sidekiq as the deploy user's systemd services (sidekiq:install installs them once).
require 'capistrano/sidekiq'
install_plugin Capistrano::Sidekiq
install_plugin Capistrano::Sidekiq::Systemd

require 'whenever/capistrano'

Dir.glob('lib/capistrano/tasks/*.rake').each { |task| import task }
