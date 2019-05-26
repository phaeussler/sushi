class CreateMinimumStocks < ActiveRecord::Migration[5.1]
  def change
    create_table :minimum_stocks do |t|
      t.integer :sku
      t.string :name
      t.integer :number_of_products
      t.integer :minimum_stock
      t.integer :ingredients_number # nuevo
      t.string :ingredient_name # nuevo
      t.integer :sku_ingredient # nuevo

      t.timestamps
    end
  end
end
