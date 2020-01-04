class CreatePicks < ActiveRecord::Migration[6.0]
  def change
    create_table :picks do |t|
      t.references :account, null: false, foreign_key: true
      t.references :brawler, null: false, foreign_key: true
      t.references :team, null: false, foreign_key: true
      t.integer :power

      t.timestamps
    end

    add_index :picks, [:account, :brawler, :team, :power], unique: true
  end
end
