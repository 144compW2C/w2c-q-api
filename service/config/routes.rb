Rails.application.routes.draw do
  namespace :auth do
    post 'login',    to: 'authentication#login'
    post 'register', to: 'authentication#register'
  end

  # =========================
  # 一般利用者向け API
  # =========================
  # /problems → Problems::ProblemsController
  resources :problems, controller: 'problems/problems', only: [:index, :show]

  # 模範解答
  get 'problems/modelAnswers/:id',
      to: 'problems/problems#model_answer'

  # 自分が作成した問題一覧
  get 'createProblem/:id',
      to: 'problems/problems#create_problem'

  # 問題の options 取得（id = problem_id）
  get 'options/:id',
      to: 'problems/options#index'

  # =========================
  # storage（回答・問題提案）
  # =========================
  namespace :storage do
    resources :answers,  only: [:index, :show, :create, :update]
    resources :problems, only: [:index, :create, :update]
  end

  # =========================
  # 管理者用 API
  # =========================
  namespace :admin do
    resources :problems, only: [:index, :show, :destroy] do
      post 'approve',  on: :member
      put  'organize', on: :member
    end
  end

  # =========================
  # その他管理リソース
  # =========================
  resources :tags, only: [:index, :show]

  resources :statuses, only: [:index, :show]
  # 仕様通り /status /status/:id も使いたい場合のエイリアス
  get  '/status',     to: 'statuses#index'
  get  '/status/:id', to: 'statuses#show'

  resources :users, only: [:index, :show, :update]
end
