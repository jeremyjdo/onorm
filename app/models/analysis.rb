class Analysis < ApplicationRecord
  belongs_to :user, optional: true
  has_one :cgvu
  has_one :cookie_system
  has_one :data_privacy
  has_one :identification

  # Validation de l'URL
  # Custom validation

  def valid_url?(url)
    uri = URI.parse(url)
    # Modif HTTP et HTTPS
    (uri.is_a?(URI::HTTP) || uri.is_a?(URI::HTTPS) && !uri.host.nil?

    # Socket ERROR ? http:s//!!!!!!!!!!!.com
    rescue URI::InvalidURIError || # Socket Error
    # doc simple form
    # error.add 'not valid'
      false
  end

  # réponse HTTP autre que 200
  # 301 ?
end
