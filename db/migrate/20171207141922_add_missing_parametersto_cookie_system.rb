class AddMissingParameterstoCookieSystem < ActiveRecord::Migration[5.1]
  def change
    add_column :cookie_systems, :cookies_list, :hash
  end
end
