Rails.application.routes.draw do
  resources :all_inventories
  root to: 'pages#home'
  resources :ftporders
  resources :orders
  resources :inventories
  resources :check
  resources :recepcion
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
