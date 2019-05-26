class CreateReceipts < ActiveRecord::Migration[5.1]
  def change
    create_table :receipts do |t|
      t.integer :sku
      t.string :name
      t.string :description
      t.integer :ingredients_number
      t.string :ingredient1
      t.string :ingredient2
      t.string :ingredient3
      t.string :ingredient4
      t.string :ingredient5
      t.string :ingredient6
      t.integer :space_for_production
      t.integer :space_for_receive_production
      t.string :production_type

      t.timestamps
    end
  end
end
