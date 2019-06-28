class PortalController < ShoppingCartController
    
    def index
        @shopping_cart_products = ShoppingCartProduct.all
        @shopping_cart_order_item = current_order.shopping_cart_order_items.new 
        @current_order = current_order
    end

    def new_attempt
        redirect_to :controller => :portal, :action => :index
    end
end