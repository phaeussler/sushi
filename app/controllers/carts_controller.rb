class CartsController < ShoppingCartController
	def show
		@current_order = current_order
		@shopping_cart_order_items = current_order.shopping_cart_order_items
	end
end