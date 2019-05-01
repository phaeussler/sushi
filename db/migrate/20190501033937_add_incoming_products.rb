class AddIncomingProducts < ActiveRecord::Migration[5.1]
  def change
    add_column :products, :incoming, :integer
  end
end
