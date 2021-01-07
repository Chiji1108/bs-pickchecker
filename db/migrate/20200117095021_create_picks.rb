class CreatePicks < ActiveRecord::Migration[6.0]
  def change
    create_table :picks do |t|
      t.references :battle, null: false, foreign_key: true
      t.references :account, null: false, foreign_key: true
      t.references :brawler, null: false, foreign_key: true
      t.references :team, null: false, foreign_key: true
      t.integer :power
      t.integer :trophies
      t.integer :trophy_change
      t.boolean :is_mvp

      t.timestamps
    end
  end
end
