class CreateModes < ActiveRecord::Migration[6.0]
  def change
    create_table :modes do |t|
      t.string :name, null: false, index: { unique: true }

      t.timestamps
    end
  end
end
