class CreateMinimumStocks < ActiveRecord::Migration[5.1]
  def change
    create_table :minimum_stocks do |t|
      t.integer :sku
      t.string :name
      t.integer :number_of_products
      t.integer :minimum_stock

      t.timestamps
    end
  end
end
