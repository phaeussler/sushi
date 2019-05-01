class CreateIngredients < ActiveRecord::Migration[5.1]
  def change
    create_table :ingredients do |t|
      t.integer :sku_product
      t.string :name_product
      t.integer :sku_ingredient
      t.string :name_ingredient
      t.float :quantity
      t.string :unit1
      t.integer :production_lot
      t.float :quantity_for_lot
      t.string :unit2
      t.float :equivalence_unit_hold

      t.timestamps
    end
  end
end
