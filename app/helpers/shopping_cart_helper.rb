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

    def update_item_quantity (item, quantity)
        if item.quantity + quantity.to_i <= 3
            item.quantity += quantity.to_i
            @shopping_cart_order.flash_quantity = false
            puts "Se actualizo la cantidad correctamente."
        else
            @shopping_cart_order.flash_quantity = true
            puts "Se supero el límite, no se actualiza."
        end
        item.save
        @shopping_cart_order.save

        should_redirect = true
        should_redirect
    end


end