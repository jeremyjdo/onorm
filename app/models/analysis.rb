class Analysis < ApplicationRecord
  belongs_to :user, optional: true
  validates :website_url, presence: true, website_url: true
  has_one :cgvu
  has_one :cookie_system
  has_one :data_privacy
  has_one :identification

  before_validation :refactor_url, only: :website_url

  private

  def test_url(url)
    RestClient.get(url)
  rescue
    false
  end

  def refactor_url
    the_url = self.website_url

    # Checks if the entry starts with http:// or https://
    if (/(^https?:\/\/)/ =~ the_url).nil?
      # if not (e.g. www.url.com or url.com) then
      # Check if the url starts with www (e.g. www.url.com)
      # if not (url.com) then
      if (/(^www.)/ =~ the_url).nil?
        http_url = "http://www.#{the_url}"
        https_url = "https://www.#{the_url}"
      # if starts with www (www.url.com) then
      else
        http_url = "http://#{the_url}"
        https_url = "https://#{the_url}"
      end
    # if the entry starts with http:// or https:// (e.g http://www.url.com) then
    else
      simple_url = the_url.gsub(/(^https?:\/\/)/, "")
      # Checks if after the http://, the url goes with www
      # if not (url.com) then
      if (/(^www.)/ =~ simple_url).nil?
        http_url = "http://www.#{simple_url}"
        https_url = "https://www.#{simple_url}"
      # if starts with www (www.url.com) then
      else
        http_url = "http://#{simple_url}"
        https_url = "https://#{simple_url}"
      end
    end

    # checks if both url work
    self.website_url = http_url if test_url(http_url)
    self.website_url = https_url if test_url(https_url)
  end
end


    #   http_url = "http://www.#{self.website_url}"
    #   https_url = "https://www.#{self.website_url}"
    #   self.website_url = http_url if test_url(http_url)
    #   self.website_url = https_url if test_url(https_url)
    #   # Checks if the entry contains http:// but not www
    #   unless test_url(self.website_url)
    #     host = URI.parse(self.website_url).host
    #     http_url = "http://#{host}"
    #     https_url = "https://#{host}"

    #   end
    # # Checks if the entry starts with www
    # elsif (/(^www)/ =~ self.website_url)
    #   http_url = "http://#{self.website_url}"
    #   https_url = "https://#{self.website_url}"
    #   self.website_url = http_url if test_url(http_url)
    #   self.website_url = https_url if test_url(https_url)
    # end
