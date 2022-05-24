Rails.application.routes.draw do
  # get 'sessions/new'
  # ログイン機能
  get    '/login', to: 'sessions#new'
  post   '/login', to: 'sessions#create'
  delete '/logout', to: 'sessions#destroy'

  root 'static_pages#top'
  get '/signup', to: 'users#new'
  get 'users/users_data', to: 'users#users_data'

  get 'users/edit_canfirmation_application', to: 'users#edit_canfirmation_application'
  post 'users/update_canfirmation_application', to: 'users#update_canfirmation_application'


  resources :users, except: [:new] do # newは上にあるのでexcept
    member do
      patch 'approve_user'
      patch 'deny_user'
    end

    resources :managements, only: [:edit] do 
      post 'update'
    end
    resources :ymw_managements, only: [:show, :edit,:destroy] do
      get 'complete_list', to: 'ymw_managements#complete_list', on: :collection
      post 'update' # 完了ボタンで使用
      post 'update_ymw_complete', on: :member # モーダルの編集で使用 
    end
  end
end

