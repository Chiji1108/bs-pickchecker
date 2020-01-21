class CreateAccessHistories < ActiveRecord::Migration[6.0]
  def change
    create_table :access_histories do |t|
      t.references :account, null: false, foreign_key: true
      t.references :battle, null: false, foreign_key: true
      # t.index [:account, :battle], unique: true

      t.timestamps
    end
  end
end
