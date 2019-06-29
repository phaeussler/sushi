class AddSkuAndQuantityToPurchaseOrders < ActiveRecord::Migration[5.1]
  def change
    add_column :purchase_orders, :sku, :string
    add_column :purchase_orders, :quantity, :integer
  end
end
