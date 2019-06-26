class ShoppingCartOrder < ApplicationRecord
    has_many :shopping_cart_order_items
    before_save :set_subtotal

    def subtotal
        shopping_cart_order_items.collect {|order_item| order_item.valid? ? (order_item.unit_price * order_item.quantity) : 0}
    end

    private
        def set_subtotal
            self[:subtotal] = subtotal
        end
end
