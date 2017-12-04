class CreateAnalyses < ActiveRecord::Migration[5.1]
  def change
    create_table :analyses do |t|
      t.references :user, foreign_key: true
      t.integer :total_score
      t.string :website_url

      t.timestamps
    end
  end
end
