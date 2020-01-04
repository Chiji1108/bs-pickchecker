class CreateProfiles < ActiveRecord::Migration[6.0]
  def change
    create_table :profiles do |t|
      t.references :account, null: false, foreign_key: true
      t.string :name
      t.integer :highestTrophies
      t.integer :highestPowerPlayPoints
      t.boolean :isQualifiedFromChampionshipChallenge
      t.integer :threeVsThreeVictories

      t.timestamps
    end

    add_index :profiles, :account, unique: true
  end
end
