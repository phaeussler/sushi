class CartsController < ShoppingCartController
	def show
		@shopping_cart_order_items = current_order.shopping_cart_order_items
	end
end