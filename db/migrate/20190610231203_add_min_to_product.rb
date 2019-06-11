class AddMinToProduct < ActiveRecord::Migration[5.1]
  def change
    add_column :products, :min, :integer, default: 0
    add_column :products, :max, :integer, default: 0
    add_column :products, :level, :integer, default: 0
  end
end
