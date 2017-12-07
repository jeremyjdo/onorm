class AddScoreToCookieSystems < ActiveRecord::Migration[5.1]
  def change
    add_column :cookie_systems, :score, :float
  end
end
