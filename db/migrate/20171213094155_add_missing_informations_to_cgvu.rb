class AddMissingInformationsToCgvu < ActiveRecord::Migration[5.1]
  def change
    add_column :cgvus, :service_presence, :boolean
    add_column :cgvus, :service_article_ref, :string
    add_column :cgvus, :service_access_presence, :boolean
    add_column :cgvus, :service_description_presence, :boolean
    add_column :cgvus, :delivery_presence, :boolean
    add_column :cgvus, :delivery_article_ref, :string
    add_column :cgvus, :delivery_modality_presence, :boolean
    add_column :cgvus, :delivery_shipping_presence, :boolean
    add_column :cgvus, :delivery_time_presence, :boolean
    add_column :cgvus, :price_presence, :boolean
    add_column :cgvus, :price_article_ref, :string
    add_column :cgvus, :price_euro_currency_presence, :boolean
    add_column :cgvus, :price_ttc_presence, :boolean
    add_column :cgvus, :price_mention_presence, :boolean
    add_column :cgvus, :payment_presence, :boolean
    add_column :cgvus, :payment_article_ref, :string
    add_column :cgvus, :payment_mention_presence, :boolean
    add_column :cgvus, :retractation_presence, :boolean
    add_column :cgvus, :retractation_article_ref, :string
    add_column :cgvus, :retractation_right_presence, :boolean
    add_column :cgvus, :contract_conclusion_presence, :boolean
    add_column :cgvus, :contract_conclusion_article_ref, :string
    add_column :cgvus, :contract_conclusion_modality_presence, :boolean
    add_column :cgvus, :contract_conclusion_agreement_presence, :boolean
    add_column :cgvus, :contract_conclusion_human_error_presence, :boolean
    add_column :cgvus, :contract_conclusion_offer_durability_presence, :boolean
    add_column :cgvus, :guaranteeandsav_presence, :boolean
    add_column :cgvus, :guaranteeandsav_article_ref, :string
    add_column :cgvus, :guaranteeandsav_guarantee_presence, :boolean
    add_column :cgvus, :guaranteeandsav_sav_presence, :boolean
  end
end
