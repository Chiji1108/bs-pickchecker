class CreateEvents < ActiveRecord::Migration[6.0]
  def change
    create_table :events do |t|
      t.integer :bs_id, null: false
      t.references :mode, null: false, foreign_key: true
      t.references :map, null: false, foreign_key: true

      t.timestamps
    end

    add_index :events, :bs_id, unique: true
  end
end
