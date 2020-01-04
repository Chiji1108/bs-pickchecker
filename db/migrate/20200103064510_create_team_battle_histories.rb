class CreateTeamBattleHistories < ActiveRecord::Migration[6.0]
  def change
    create_table :team_battle_histories do |t|
      t.references :team, null: false, foreign_key: true
      t.references :battle, null: false, foreign_key: true
      t.string :result
      t.index [:team, :battle, :result], unique: true, name: 'team_battle_histories_composite_index'

      t.timestamps
    end
  end
end
