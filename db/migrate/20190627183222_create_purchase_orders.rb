class CreatePurchaseOrders < ActiveRecord::Migration[5.1]
  def change
    create_table :purchase_orders do |t|
      t.string :client
      t.decimal :latitude
      t.decimal :longitude
      t.float :total
      t.string :proveedor
      t.string :products

      t.timestamps
    end
  end
end
