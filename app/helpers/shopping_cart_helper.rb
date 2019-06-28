module ShoppingCartHelper

    def current_order
        if !session[:order_id].nil?
            ShoppingCartOrder.find(session[:order_id])
        else
            ShoppingCartOrder.new
        end
    end

    def total_items
        n_items = 0
        current_order.shopping_cart_order_items.each do |item|
            n_items += item.quantity
        end
        n_items
    end
end