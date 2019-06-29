class AddFlashSkuAndFlashQuantityAndFlashOrderToShoppingCartOrders < ActiveRecord::Migration[5.1]
  def change
    add_column :shopping_cart_orders, :flash_sku, :boolean
    add_column :shopping_cart_orders, :flash_quantity, :boolean
    add_column :shopping_cart_orders, :flash_order, :boolean
  end
end
