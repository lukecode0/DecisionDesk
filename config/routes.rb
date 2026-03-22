Rails.application.routes.draw do
  root 'home#index'
  get '/app', to: 'home#app'

  namespace :api do
    resource :health, only: :show, controller: 'health'
    get '/bootstrap', to: 'demo#bootstrap'
    post '/reset', to: 'demo#reset'
    resources :submissions, only: [:index, :show, :create]
  end
end
