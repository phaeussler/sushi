class ShoppingCartOrderItemsController < ShoppingCartController
    
    def create
        @shopping_cart_order = current_order
        @shopping_cart_order_item = @shopping_cart_order.shopping_cart_order_items.new(shopping_cart_order_item_params)
        @shopping_cart_order.save
        session[:order_id] = @shopping_cart_order.id
    end

    private
        def shopping_cart_order_item_params
            params.require(:shopping_cart_order_item).permit(:shopping_cart_product_id, :quantity)
        end
end
