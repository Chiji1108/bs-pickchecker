class CreateAccounts < ActiveRecord::Migration[6.0]
  def change
    create_table :accounts do |t|
      t.string :tag, null: false, index: { unique: true }
      t.references :player, null: true, foreign_key: true
      t.string :note

      t.timestamps
    end
  end
end
