class CreateIdentifications < ActiveRecord::Migration[5.1]
  def change
    create_table :identifications do |t|
      t.references :analysis, foreign_key: true
      t.integer :score

      t.timestamps
    end
  end
end
