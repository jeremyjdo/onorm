class WebsiteUrlValidator < ActiveModel::EachValidator

  def self.compliant?(value)
    uri = URI.parse(value)
    uri.is_a?(URI::HTTP) && !uri.host.nil?
  rescue URI::InvalidURIError
    false
  end

  def self.exist?(value)
    code = RestClient.get(value)
  # rescue Redirect => e
  # redirected_url = e.url
  rescue
    false
  end

  def validate_each(record, attribute, value)
    if value.present? && self.class.compliant?(value)
      unless self.class.exist?(value)
        record.errors.add(attribute, "L'adresse entrée semble inaccessible")
      end
    else
      record.errors.add(attribute, "Vous devez entrer une adresse URL valide")
    end
  end
end
