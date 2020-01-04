class CreateAccounts < ActiveRecord::Migration[6.0]
  def change
    create_table :accounts do |t|
      t.string :tag, null: false
      t.references :player, null: true, foreign_key: true
      t.string :note

      t.timestamps
    end

    add_index :accounts, :tag, unique: true
  end
end
