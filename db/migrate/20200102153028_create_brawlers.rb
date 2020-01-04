class CreateBrawlers < ActiveRecord::Migration[6.0]
  def change
    create_table :brawlers do |t|
      t.integer :bs_id, null: false, unique: true
      t.string :name, null: false, unique: true

      t.timestamps
    end
  end
end
