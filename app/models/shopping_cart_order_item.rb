class ShoppingCartOrderItem < ApplicationRecord
    belongs_to :shopping_cart_order
    belongs_to :shopping_cart_product

    before_save :set_unit_price
    before_save :set_total_price

    def unit_price
        if persisted?
            self[:unit_price]
        else
            shopping_cart_product.price
        end
    end

    def total_price
        unit_price * quantity
    end

    private
        def set_unit_price
            self[:unit_price] = unit_price
        end

        def set_total_price
            self[:total_price] = quantity * set_unit_price
        end

end
