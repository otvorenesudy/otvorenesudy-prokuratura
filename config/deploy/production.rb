set :stage, :production
set :branch, 'main'
set :app_path, "#{fetch(:application)}-#{fetch(:stage)}"
set :rails_env, :production
set :deploy_to, "/home/deploy/projects/#{fetch(:app_path)}"
set :user, 'deploy'

server '37.9.168.190', user: fetch(:user), roles: %w[app db web worker]
