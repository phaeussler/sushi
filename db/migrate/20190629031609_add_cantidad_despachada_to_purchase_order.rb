class AddCantidadDespachadaToPurchaseOrder < ActiveRecord::Migration[5.1]
  def change
    add_column :purchase_orders, :cantidad_despachada, :integer, default: 0
  end
end
