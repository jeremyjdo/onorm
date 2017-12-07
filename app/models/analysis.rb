class Analysis < ApplicationRecord
  belongs_to :user, optional: true
  validates :website_url, presence: true, website_url: true
  has_one :cgvu
  has_one :cookie_system
  has_one :data_privacy
  has_one :identification

  # before_validation :refactor_url, only: :website_url

  # private

  # def refactor_url
  #   self.website_url = "http://www.#{self.website_url}" if (/((^http:\/\/)(www))|((^https:\/\/)(www))/ =~ self.website_url).nil?
  #   self.website_url = "https://www.#{self.website_url}" if !open(self.website_url).read
  # end
end
