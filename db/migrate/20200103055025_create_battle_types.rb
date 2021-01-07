class CreateBattleTypes < ActiveRecord::Migration[6.0]
  def change
    create_table :battle_types do |t|
      t.string :name, null: false, index: { unique: true }

      t.timestamps
    end
  end
end
