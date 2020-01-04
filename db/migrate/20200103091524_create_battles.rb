class CreateBattles < ActiveRecord::Migration[6.0]
  def change
    create_table :battles do |t|
      t.references :event, null: false, foreign_key: true
      t.references :battle_type, null: false, foreign_key: true
      t.datetime :time
      t.integer :duration

      t.timestamps
    end
  end
end
