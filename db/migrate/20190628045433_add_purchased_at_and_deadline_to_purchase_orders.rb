class AddPurchasedAtAndDeadlineToPurchaseOrders < ActiveRecord::Migration[5.1]
  def change
    add_column :purchase_orders, :purchased_at, :datetime
    add_column :purchase_orders, :deadline, :datetime
  end
end
