class CreateBattleTypes < ActiveRecord::Migration[6.0]
  def change
    create_table :battle_types do |t|
      t.string :name, null: false

      t.timestamps
    end

    add_index :battle_types, :name, unique: true
  end
end
