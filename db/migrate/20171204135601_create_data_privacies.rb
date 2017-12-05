class CreateDataPrivacies < ActiveRecord::Migration[5.1]
  def change
    create_table :data_privacies do |t|
      t.references :analysis, foreign_key: true
      t.boolean :presence

      t.timestamps
    end
  end
end
