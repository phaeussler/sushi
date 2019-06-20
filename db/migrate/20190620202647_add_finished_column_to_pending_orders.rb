class AddFinishedColumnToPendingOrders < ActiveRecord::Migration[5.1]
  def change
    add_column :pending_orders, :finished, :boolean, default: false
  end
end
