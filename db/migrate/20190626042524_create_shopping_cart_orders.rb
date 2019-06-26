class CreateShoppingCartOrders < ActiveRecord::Migration[5.1]
  def change
    create_table :shopping_cart_orders do |t|
      t.integer :subtotal
      t.integer :total
      t.float :tax
      t.float :shipping

      t.timestamps
    end
  end
end
