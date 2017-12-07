class WebsiteUrlValidator < ActiveModel::EachValidator

  def self.compliant?(value)
    uri = URI.parse(value)
    uri.is_a?(URI::HTTP) && !uri.host.nil?
  rescue URI::InvalidURIError
    false
  end

  def validate_each(record, attribute, value)
    unless value.present? && self.class.compliant?(value)
      record.errors.add(attribute, "Vous devez entrer une adresse HTTP valide")
    end
  end
end

  # def valid_url?(url)
  #   uri = URI.parse(url)
  #   # Modif HTTP et HTTPS
  #   (uri.is_a?(URI::HTTP) || uri.is_a?(URI::HTTPS) && !uri.host.nil?

  #   # Socket ERROR ? http:s//!!!!!!!!!!!.com
  #   rescue URI::InvalidURIError || # Socket Error
  #   # doc simple form
  #   # error.add 'not valid'
  #     false
  # end

  # # réponse HTTP autre que 200
  # # 301
