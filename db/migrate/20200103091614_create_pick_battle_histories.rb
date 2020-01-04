class CreatePickBattleHistories < ActiveRecord::Migration[6.0]
  def change
    create_table :pick_battle_histories do |t|
      t.references :pick, null: false, foreign_key: true
      t.references :battle, null: false, foreign_key: true
      t.integer :trophy_change
      t.boolean :is_mvp

      t.timestamps
    end
  end
end
