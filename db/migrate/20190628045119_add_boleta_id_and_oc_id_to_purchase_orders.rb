class AddBoletaIdAndOcIdToPurchaseOrders < ActiveRecord::Migration[5.1]
  def change
    add_column :purchase_orders, :boleta_id, :string
    add_column :purchase_orders, :oc_id, :string
  end
end
