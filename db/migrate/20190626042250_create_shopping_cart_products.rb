class CreateShoppingCartProducts < ActiveRecord::Migration[5.1]
  def change
    create_table :shopping_cart_products do |t|
      t.string :title
      t.integer :sku
      t.string :description
      t.integer :price

      t.timestamps
    end
  end
end
