class AddIdentificationAnalysisResultsToIdentification < ActiveRecord::Migration[5.1]
  def change
    add_column :identifications, :company_name_presence, :boolean
    add_column :identifications, :legal_form_presence, :boolean
    add_column :identifications, :legal_form_text, :text
    add_column :identifications, :address_presence, :boolean
    add_column :identifications, :address_text, :text
    add_column :identifications, :capital_presence, :boolean
    add_column :identifications, :capital_text, :text
    add_column :identifications, :email_presence, :boolean
    add_column :identifications, :email_text, :text
    add_column :identifications, :phone_presence, :boolean
    add_column :identifications, :phone_text, :text
    add_column :identifications, :publication_director_presence, :boolean
    add_column :identifications, :publication_director_text, :text
    add_column :identifications, :rcs_presence, :boolean
    add_column :identifications, :rcs_text, :text
    add_column :identifications, :tva_presence, :boolean
    add_column :identifications, :tva_text, :text
    add_column :identifications, :host_name_presence, :boolean
    add_column :identifications, :host_address_presence, :boolean
    add_column :identifications, :host_phone_presence, :boolean
    add_column :identifications, :host_text, :text
  end
end
