class CartsController < ShoppingCartController
	def show
		@current_order = current_order
		@current_order.flash_quantity = false
        @current_order.flash_sku = false
        @current_order.save
		@shopping_cart_order_items = current_order.shopping_cart_order_items
	end
end