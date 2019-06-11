class AddIncomingProducts < ActiveRecord::Migration[5.1]
  def change
    add_column :products, :incoming, :integer, default: 0
  end
end
