class CreatePendingOrders < ActiveRecord::Migration[5.1]
  def change
    create_table :pending_orders do |t|
      t.integer :oc_id
      t.string :reception_date
      t.string :dispatch_max_date

      t.timestamps
    end
  end
end