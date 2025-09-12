set :stage, :production
set :branch, 'main'
set :app_path, "#{fetch(:application)}-#{fetch(:stage)}"
set :rails_env, :production
set :deploy_to, "/home/deploy/projects/#{fetch(:app_path)}"
set :user, 'deploy'

server 'otvorenesudy1.server.wbsprt.com', user: fetch(:user), roles: %w[app db web worker]
