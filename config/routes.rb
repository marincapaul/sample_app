Rails.application.routes.draw do
  get 'passwor_resets/new'
  get 'passwor_resets/edit'
  
  

  root 'static_pages#home'
  # get 'static_pages/home'
  get     '/help',      to: 'static_pages#help'
  get     '/about',     to: 'static_pages#about'
  get     '/contact',   to: 'static_pages#contact'
  get     '/signup',    to: 'users#new'
  get     '/login',     to: 'sessions#new'
  post    '/login',     to: 'sessions#create'
  delete  '/logout',    to: 'sessions#destroy'
  
  resources :users
  resources :account_activations, only: [:edit]
  resources :passwor_resets,      only: [:new, :create, :edit, :update]
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"
  
end
