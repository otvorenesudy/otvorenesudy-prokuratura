Rails.application.routes.draw do
  root to: 'static_pages#home'

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
