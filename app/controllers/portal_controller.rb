class PortalController < ShoppingCartController
    
    def index
        @shopping_cart_products = ShoppingCartProduct.all
        @shopping_cart_order_item = current_order.shopping_cart_order_items.new 
        @current_order = current_order

        @flash_infeasible = false
        puts "parametro :infeasible"
        puts params[:infeasible]
        if !params[:infeasible].nil?
            @flash_infeasible = true
        end
    end

    def new_attempt
        redirect_to :controller => :portal, :action => :index
    end

    def infeasible_order
        reset_session
        redirect_to :controller => :portal, :action => :index, :infeasible => true
    end
end