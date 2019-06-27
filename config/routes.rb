Rails.application.routes.draw do
  resources :all_inventories
  root to: 'pages#home'
  resources :ftporders
  resources :orders
  resources :inventories
  resources :check
  resources :recepcion
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  resources :shopping_cart_products
  resources :shopping_cart_order_items
  resource :carts, only: [:show]
  get 'portal/' => 'portal#index'

end
