class CreateBattles < ActiveRecord::Migration[6.0]
  def change
    create_table :battles do |t|
      t.references :event, null: false, foreign_key: true
      t.references :battle_type, null: false, foreign_key: true
      t.datetime :time
      t.integer :duration

      t.timestamps
    end

    add_index :battles, [:event, :battle_type, :time, :duration], unique: true
  end
end
