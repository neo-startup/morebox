Rails.application.routes.draw do
  get 'cards/index'
  get 'cards/new'
  get 'cards/create'
  get 'users/pay_complete'
  root 'products#marketing'
  get 'home/index'
  get 'home/calorie_start'
  post 'apis/pay_url'
  post 'apis/pay_complete'
  # get 'apis/pay_complete'

  get '/survey' => "home#survey"
  get '/survey_start' => "home#survey_start"
  get '/fit_table' => "home#fit_table"
  get '/fit_table/survey' => "users#market"

  get 'home/exception'
  get 'home/policy'
  devise_for :admin_users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)
  devise_for :users, controllers: { sessions: 'users/sessions', registrations: 'users/registrations', passwords: 'users/passwords', confirmations: 'users/confirmations', omniauth_callbacks: 'users/omniauth_callbacks' }
  resources :users do
    collection do
      get :check
      post :check_certificate
      get :check_and_send_message
      get :ronie
    end
    member do
      post :pay_complete
      get :pay_complete
      get :update_referrer
      post :updating_referrer
    end
  end
  resources :items, only: [:index, :show] do
    collection do
      get 'auto_out'
      get :list
      get :send_survey
    end
  end
  resources :line_items, only: [:update, :create, :destroy] do
    member do
      get 'reduce'
    end
  end
  resources :orders do
    collection do
      get :payment
      get :complete
      get :send_kakao
    end
  end
  resources :gyms do
    collection do
      get :total_dashboard
    end
  end

  resources :diets do
    collection do
      get :recommend
    end
  end
  resources :points

  resources :posts, only: [:index, :create, :show, :update] do
    collection do
      get :complete
    end
    member do
      get :loading
    end
  end

  resources :reports, only: [:new, :create, :show]
  resources :cards
end
