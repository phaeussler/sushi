module ShoppingCartHelper

    def current_order
        if !session[:order_id].nil?
            ShoppingCartOrder.find(session[:order_id])
        else
            ShoppingCartOrder.new
        end
    end
end