class CreateBrawlers < ActiveRecord::Migration[6.0]
  def change
    create_table :brawlers do |t|
      t.integer :bs_id, null: false
      t.string :name, null: false

      t.timestamps
    end

    add_index :brawlers, :bs_id, unique: true
  end
end
