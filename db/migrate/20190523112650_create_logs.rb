class CreateLogs < ActiveRecord::Migration[5.1]
  def change
    create_table :logs do |t|
      t.integer :id_caso
      t.string :activity
      t.integer :group
      t.integer :sku
      t.integer :price
      t.string :status
    end
  end
end
