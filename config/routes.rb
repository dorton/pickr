Rails.application.routes.draw do
  resources :groups
  resources :picks
  resources :games
  devise_for :users
  resources :matchups
  root "home#index"
  post 'adduser', to: 'home#adduser', as: 'adduser'
  post 'removeuser', to: 'home#remove_user', as: 'remove_user'
  get 'manage/groups', to: 'home#manage_groups', as: 'manage_groups'
  get ':group_slug', to: 'home#group', as: 'grouphome'
  get ':group_slug/:week_id', to: 'home#index', as: 'groupweekhome'
  get ':group_slug/:week_id/picks', to: 'home#show'
  get ':group_slug/:week_id/picks/:user_id', to: 'home#adminedit', as: 'adminedit'
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  # root "posts#index"
end
