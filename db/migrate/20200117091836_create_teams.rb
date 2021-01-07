class CreateTeams < ActiveRecord::Migration[6.0]
  def change
    create_table :teams do |t|
      t.string :result
      t.integer :rank

      t.timestamps
    end
  end
end
