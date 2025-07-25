Rails.application.routes.draw do
  namespace :auth do
    post 'login', to: 'authentication#login'
    post 'register', to: 'authentication#register'
  end

  resources :users, only: [:index, :show, :create, :update, :destroy] 
end
