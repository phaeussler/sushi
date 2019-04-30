class CreateAssignations < ActiveRecord::Migration[5.1]
  def change
    create_table :assignations do |t|
      t.integer :sku
      t.string :name
      t.integer :group

      t.timestamps
    end
  end
end
