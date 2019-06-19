class CreatePendingOrders < ActiveRecord::Migration[5.1]
  def change
    create_table :pending_orders do |t|
      t.string :id_oc
      t.string :reception_date
      t.string :max_dispatch_date
      t.timestamps
    end
  end
end
