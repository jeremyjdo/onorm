class CreateCookieSystems < ActiveRecord::Migration[5.1]
  def change
    create_table :cookie_systems do |t|
      t.references :analysis, foreign_key: true
      t.boolean :cookie_usage
      t.boolean :cookie_user_agreement

      t.timestamps
    end
  end
end
