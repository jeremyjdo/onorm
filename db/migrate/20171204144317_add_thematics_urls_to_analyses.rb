class AddThematicsUrlsToAnalyses < ActiveRecord::Migration[5.1]
  def change
    add_column :analyses, :identification_url, :string
    add_column :analyses, :cgvu_url, :string
    add_column :analyses, :data_privacy_url, :string
    add_column :analyses, :cookie_system_url, :string
  end
end
