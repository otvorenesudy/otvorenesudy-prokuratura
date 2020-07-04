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

  resource :static_page, only: [] do
    get :about
    get :faq
    get :feedback
    get :tos
    get :privacy
    get :contact
    get :copyright
  end
end
