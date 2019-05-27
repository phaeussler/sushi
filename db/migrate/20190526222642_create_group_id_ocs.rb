class CreateGroupIdOcs < ActiveRecord::Migration[5.1]
  def change
    create_table :group_id_ocs do |t|
      t.integer :group
      t.string :id_development
      t.string :id_production

      t.timestamps
    end
  end
end
