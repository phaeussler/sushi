class CreateOrders < ActiveRecord::Migration[5.1]
  def change
    create_table :orders do |t|
      t.integer :sku
      t.integer :almacenId
      t.integer :cantidad
      t.timestamps
    end
  end
end
