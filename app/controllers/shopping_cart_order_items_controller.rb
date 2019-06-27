class ShoppingCartOrderItemsController < ShoppingCartController
    
    def create
        @shopping_cart_order = current_order
        puts 'el parametro es: '
        puts params[:shopping_cart_order_item]
        puts params
        if !@shopping_cart_order.shopping_cart_order_items.find_by(shopping_cart_product_id: params[:shopping_cart_order_item][:shopping_cart_product_id]).nil?
            @existing_item = @shopping_cart_order.shopping_cart_order_items.find_by(shopping_cart_product_id: params[:shopping_cart_order_item][:shopping_cart_product_id])
            puts @existing_item.shopping_cart_product_id
            puts '*******50'
            @existing_item.update_attributes(shopping_cart_order_item_params)
            puts 'El producto existe en el carro.'
        else
            puts 'El producto no existe en el carro.'
            puts '*******100'
            @shopping_cart_order_item = @shopping_cart_order.shopping_cart_order_items.new(shopping_cart_order_item_params)
            @shopping_cart_order.save
        end
        session[:order_id] = @shopping_cart_order.id

    end

    def update
		@shopping_cart_order = current_order
		@shopping_cart_order_item = @shopping_cart_order.shopping_cart_order_items.find_by(params[:shopping_cart_order_item][:shopping_cart_product_id])
		@shopping_cart_order_item.update(shopping_cart_order_item_params)
        @shopping_cart_order_items = @shopping_cart_order.shopping_cart_order_items
    end
    
    def destroy
		@shopping_cart_order = current_order
		@shopping_cart_order_item = @shopping_cart_order.shopping_cart_order_items.find_by(params[:shopping_cart_product_id])
		@shopping_cart_order_item.destroy
        @shopping_cart_order_items = @shopping_cart_order.shopping_cart_order_items
    end
	

    private
        def shopping_cart_order_item_params
            params.require(:shopping_cart_order_item).permit(:shopping_cart_product_id, :quantity)
        end
end
