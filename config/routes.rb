Rails.application.routes.draw do
  get 'pending_purchase_orders/create'

  get 'pending_purchase_order/create'

  resources :purchase_orders
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
  get 'portal/new_attempt' => 'portal#new_attempt'
  get 'portal/infeasible_order' => 'portal#infeasible_order'

  get 'purchase_orders/(:format)/success' => 'purchase_orders#success'
  get 'purchase_orders/(:fail)/fail' => 'purchase_orders#fail'

end
