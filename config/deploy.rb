# config valid for current version and patch releases of Capistrano
lock '~> 3.14.1'

set :application, 'opencourts-prokuratura'
set :repo_url, 'git@github.com:otvorenesudy/otvorenesudy-prokuratura.git'

# Sidekiq
set :sidekiq_processes, 1

# Rbenv
set :rbenv_type, :user
set :rbenv_ruby, File.read('.ruby-version').strip

# Whenever
set :whenever_identifier, -> { "#{fetch(:application)}-#{fetch(:stage)}" }

# Links
set :linked_files, fetch(:linked_files, []).push('config/master.key', 'config/credentials/production.key')
set :linked_dirs,
    fetch(:linked_dirs, []).push('log', 'tmp/pids', 'tmp/cache', 'tmp/sockets', 'tmp/downloads', 'vendor/bundle')

set :keep_releases, 2
set :ssh_options, { forward_agent: true }

namespace :deploy do
  before 'deploy:assets:precompile', 'deploy:yarn_install'

  after 'deploy:publishing', 'deploy:restart'
  after 'finishing', 'deploy:cleanup'

  desc 'Deploy app for first time'
  task :cold do
    invoke 'deploy:starting'
    invoke 'deploy:started'
    invoke 'deploy:updating'
    invoke 'bundler:install'
    invoke 'deploy:database' # This replaces deploy:migrations
    invoke 'deploy:compile_assets'
    invoke 'deploy:normalize_assets'
    invoke 'deploy:publishing'
    invoke 'deploy:published'
    invoke 'deploy:finishing'
    invoke 'deploy:finished'
  end

  desc 'Setup database'
  task :database do
    on roles(:db) do
      within release_path do
        with rails_env: (fetch(:rails_env) || fetch(:stage)) do
          execute :rake, 'db:create'
          execute :rake, 'db:migrate'
          execute :rake, 'db:seed'
        end
      end
    end
  end

  namespace :deploy do
    desc 'Run rake yarn:install'
    task :yarn_install do
      on roles(:web) do
        within release_path do
          execute("cd #{release_path} && yarn install")
        end
      end
    end
  end
end