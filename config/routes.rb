Rails.application.routes.draw do
  get 'battles', to: 'battles#index'
  get 'battles/select_mode', to: 'battles#select_mode'
  post 'battles/select_mode', to: 'battles#search_mode'
  get 'battles/:mode_id/select_map', to: 'battles#select_map'
  post 'battles/:mode_id/select_map', to: 'battles#search_map'
  get 'battles/select_player', to: 'battles#select_player'
  post 'battles/select_player', to: 'battles#search_player'
  mount RailsAdmin::Engine => '/admin', as: 'rails_admin'
  resources :players, param: :name
  resources :accounts, param: :tag do
    collection do
      post 'search'
    end
  end
  root 'players#index'
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end