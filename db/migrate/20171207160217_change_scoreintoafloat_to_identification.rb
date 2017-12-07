class ChangeScoreintoafloatToIdentification < ActiveRecord::Migration[5.1]
  def change
    change_column :identifications, :score, :float
  end
end
