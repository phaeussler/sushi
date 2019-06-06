class CreateAllInventories < ActiveRecord::Migration[5.1]
  def change
    create_table :all_inventories do |t|

      t.timestamps
    end
  end
end
