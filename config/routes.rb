require 'sidekiq/web'

Rails.application.routes.draw do
  root to: 'static_pages#home'

  if Rails.env.production?
    Sidekiq::Web.use Rack::Auth::Basic do |username, password|
      ActiveSupport::SecurityUtils.secure_compare(
        ::Digest::SHA256.hexdigest(username),
        ::Digest::SHA256.hexdigest(Rails.application.credentials.dig(:sidekiq, :username))
      ) &&
        ActiveSupport::SecurityUtils.secure_compare(
          ::Digest::SHA256.hexdigest(password),
          ::Digest::SHA256.hexdigest(Rails.application.credentials.dig(:sidekiq, :password))
        )
    end
  end

  mount Sidekiq::Web, at: '/sidekiq'

  resources :offices, only: %i[index show] do
    get :suggest, on: :collection
  end

  resources :prosecutors, only: %i[index show] do
    get :suggest, on: :collection
  end

  resources :statistics, only: :index, path: :criminality do
    get :suggest, on: :collection
    get :png, on: :collection
    get :export, on: :collection
    get :embed, on: :collection
  end

  # error pages
  %w[400 404 422 500 503].each { |code| get "/#{code}", to: 'errors#show', code: code }

  match '/:slug', via: :get, to: 'static_pages#show', as: :static_page
end
