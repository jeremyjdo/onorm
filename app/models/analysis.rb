class Analysis < ApplicationRecord
  belongs_to :user
  has_one :cgvu
  has_one :cookie_system
  has_one :data_privacy
  has_one :identification
end
