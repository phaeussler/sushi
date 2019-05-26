class CreateProducts < ActiveRecord::Migration[5.1]
  def change
    create_table :products do |t|
      t.integer :sku
      t.string :name
      t.string :description
      t.string :cost_lot_production
      t.integer :sell_price
      t.integer :ingredients
      t.integer :used_by
      t.float :expected_duration_hours
      t.float :equivalence_units_hold
      t.string :unit
      t.string :production_lot
      t.float :expected_time_production_mins
      t.string :groups
      t.integer :total_productor_groups
      t.string :production_type

      t.timestamps
    end
  end
end
