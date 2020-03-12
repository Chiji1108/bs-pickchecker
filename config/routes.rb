Rails.application.routes.draw do
  get 'battles', to: 'battles#index'
  mount RailsAdmin::Engine => '/admin', as: 'rails_admin'
  resources :players, param: :name
  resources :accounts, param: :tag do
    collection do
      get 'search', to: 'accounts#index'
      post 'search'
    end
  end
  root 'players#index'
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
