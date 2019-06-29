class AddCreatedAndFinishedToPurchaseOrders < ActiveRecord::Migration[5.1]
  def change
    add_column :purchase_orders, :created, :boolean, default: false
    add_column :purchase_orders, :finished, :boolean, default: false
  end
end
