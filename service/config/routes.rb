Rails.application.routes.draw do
  namespace :auth do
    post 'login', to: 'authentication#login'
    post 'register', to: 'authentication#register'
  end

  # 一般利用者向けAPI
  resources :problems, only: [:index, :show] do
    get 'modelAnswers', to: 'problems#model_answer', on: :member
    resources :options, only: [:index, :create]
  end

  namespace :storage do
    resources :answers, only: [:index, :show, :create, :update]
    resources :problems, only: [:create, :update]
  end

  # 管理者用API
  namespace :admin do
    resources :problems, only: [:index, :show, :destroy] do
      post 'approve', on: :member
      put 'organize', on: :member
    end
  end

  # その他管理リソース
  resources :tags, only: [:index, :show]
  resources :statuses, only: [:index, :show]
  resources :users, only: [:index, :show, :update]

end