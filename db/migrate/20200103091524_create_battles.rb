class CreateBattles < ActiveRecord::Migration[6.0]
  def change
    create_table :battles do |t|
      t.references :event, null: false, foreign_key: true
      t.references :battle_type, null: false, foreign_key: true
      t.datetime :time
      t.integer :duration
      t.index [:event, :battle_type, :time, :duration], unique: true, name: 'battles_composite_index'

      t.timestamps
    end
  end
end
