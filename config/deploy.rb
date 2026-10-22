# frozen_string_literal: true

# Deployed with `bundle exec cap production deploy`, from main.
lock '~> 3.20'

set :application, 'otvorenesudy-prokuratura'
set :repo_url,
    'git@github.com-otvorenesudy-prokuratura:otvorenesudy/otvorenesudy-prokuratura.git'
# set :repo_url, 'git@github.com:otvorenesudy/otvorenesudy-prokuratura.git' # Uncomment when deploying locally

set :ssh_options, { forward_agent: true }

set :rbenv_type, :user
set :rbenv_ruby, File.read('.ruby-version').strip

# The secrets' key (config/credentials/production.yml.enc is committed); the database login comes from the deploy
# user's ~/.env.
set :linked_files,
    fetch(:linked_files, []).push('config/credentials/production.key')
set :linked_dirs, fetch(:linked_dirs, []).push(
  'log', 'tmp/pids', 'tmp/cache', 'tmp/sockets', 'tmp/downloads', 'vendor/bundle'
)

set :keep_releases, 2

set :whenever_identifier, -> { "#{fetch(:application)}-#{fetch(:stage)}" }

# Two Sidekiq processes, each the deploy user's systemd service (sidekiq:install installs them once).
set :sidekiq_config_files, %w[sidekiq-1.yml sidekiq-2.yml]
set :sidekiq_service_unit_name, -> { "#{fetch(:application)}.sidekiq" }
set :sidekiq_service_unit_env_files, -> { ["/home/#{fetch(:user)}/.env"] }

namespace :deploy do
  after 'deploy:publishing', 'deploy:restart'
  after 'finishing', 'deploy:cleanup'
  after 'finishing', 'cache:clear'

  desc 'Deploy to a new server: create and load the database instead of migrating it'
  task :cold do
    invoke 'deploy:starting'
    invoke 'deploy:started'
    invoke 'deploy:updating'
    invoke 'bundler:install'
    invoke 'deploy:prepare_database'
    invoke 'sidekiq:install'
    invoke 'deploy:compile_assets'
    invoke 'deploy:normalize_assets'
    invoke 'deploy:publishing'
    invoke 'deploy:published'
    invoke 'deploy:finishing'
    invoke 'deploy:finished'
  end

  desc 'Create the database and load db/structure.sql with the seeds, or migrate an existing one'
  task :prepare_database do
    on roles(:db) do
      within release_path do
        with rails_env: fetch(:rails_env) || fetch(:stage) do
          execute :rake, 'db:prepare'
        end
      end
    end
  end
end

namespace :cache do
  desc 'Clear the Rails cache'
  task :clear do
    on roles(:app) do
      within current_path do
        with rails_env: fetch(:rails_env) do
          execute :rake, 'cache:clear'
        end
      end
    end
  end
end
