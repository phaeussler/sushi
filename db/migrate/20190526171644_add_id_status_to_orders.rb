class AddIdStatusToOrders < ActiveRecord::Migration[5.1]
  def change
    add_column :orders, :id_oc, :integer, default: 0
    add_column :orders, :status, :string, default: ""
    add_column :orders, :precio, :integer, default: 0
  end
end
