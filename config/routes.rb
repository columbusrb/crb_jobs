Rails.application.routes.draw do

  require 'sidekiq/web'
  mount Sidekiq::Web => '/sidekiq'

  resources :candidates
  resources :jobs

  get '/search', to: 'searches#new', as: 'search'
  get '/unsubscribe/:token', to: 'candidates#unsubscribe', as: 'unsubscribe'
  get '/remove_account/:token', to: 'candidates#destroy', as: 'remove_account'

  root to: "jobs#index"

end
