class ShoppingCartOrderItemsController < ShoppingCartController
    
    def create
        should_redirect = false
        @shopping_cart_order = current_order
        puts params

        if !@shopping_cart_order.shopping_cart_order_items.find_by(shopping_cart_product_id: params[:shopping_cart_order_item][:shopping_cart_product_id]).nil?
            @existing_item = @shopping_cart_order.shopping_cart_order_items.find_by(shopping_cart_product_id: params[:shopping_cart_order_item][:shopping_cart_product_id])
            puts @existing_item.shopping_cart_product_id
            #@existing_item.update_attributes(shopping_cart_order_item_params)
            puts 'El producto existe en el carro.'
            puts @existing_item
            puts params[:shopping_cart_order_item][:quantity]
            should_redirect = update_item_quantity(@existing_item, params[:shopping_cart_order_item][:quantity])
            if @shopping_cart_order.flash_sku? 
                @shopping_cart_order.flash_sku = false
                @shopping_cart_order.save
                should_redirect = true
            end

        else
            puts 'El producto no existe en el carro.'
            # Se chequea que no hayan otros:
            if !@shopping_cart_order.shopping_cart_order_items.empty?
                @shopping_cart_order.flash_sku = true
                @shopping_cart_order.save
                should_redirect = true
            else
                @shopping_cart_order.flash_sku = false
                @shopping_cart_order.save
                @shopping_cart_order_item = @shopping_cart_order.shopping_cart_order_items.new(shopping_cart_order_item_params)
                @shopping_cart_order.save
            end
        end
        
        session[:order_id] = @shopping_cart_order.id
        if should_redirect
            puts "Los FLASH"
            puts @shopping_cart_order.flash_sku
            puts @shopping_cart_order.flash_quantity
           redirect_to :controller => :portal, :action => :index
        end

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
