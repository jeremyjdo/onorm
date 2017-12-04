class CreateCgvus < ActiveRecord::Migration[5.1]
  def change
    create_table :cgvus do |t|
      t.references :analysis, foreign_key: true
      t.integer :score

      t.timestamps
    end
  end
end
