Rails.application.routes.draw do
  devise_for :users

  authenticated :user do
    root 'dashboard#index', as: :authenticated_root
  end

  root 'dashboard#index'

  resources :products
  resources :warehouses
  resources :inventories, only: %i[index show]
  resources :stock_movements, only: %i[index new create show]

  get 'up' => 'rails/health#show', as: :rails_health_check
end
