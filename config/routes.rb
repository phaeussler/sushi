Rails.application.routes.draw do
  root to: 'pages#home'
  resources :orders
  resources :inventories
  resources :check
  resources :recepcion
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
