Rails.application.routes.draw do
  namespace :admin do
    resources :calendars
    resources :games
    resources :groups
    resources :group_games
    resources :group_managers
    resources :group_picks
    resources :matchups
    resources :odds
    resources :picks
    resources :settings
    resources :users
    resources :user_groups
    resources :user_group_defaults

    root to: 'calendars#index'
  end
  resources :settings
  resources :groups, param: :slug do
    resources :group_users, only: %i[create destroy]
    resources :group_managers, only: %i[create destroy]
  end
  resources :picks
  resources :games
  devise_for :users
  resources :matchups
  get 'manage/groups', to: 'home#manage_groups', as: 'manage_groups'
  get ':group_slug', to: 'home#group', as: 'grouphome'
  get ':group_slug/:week_id', to: 'home#index', as: 'groupweekhome'
  get ':group_slug/:week_id/picks', to: 'home#show'
  get ':group_slug/:week_id/picks/:user_id', to: 'home#adminedit', as: 'adminedit'

  get 'up' => 'rails/health#show', as: :rails_health_check

  # Defines the root path route ("/")
  root 'home#index'
end
