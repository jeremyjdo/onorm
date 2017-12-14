class AddOfferDurabilityToCgvu < ActiveRecord::Migration[5.1]
  def change
    add_column :cgvus, :offer_durability_presence, :boolean
    add_column :cgvus, :offer_durability_article_ref, :string
  end
end
