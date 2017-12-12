class CookieSystem < ApplicationRecord
  belongs_to :analysis
  after_create :broadcast_data

  def broadcast_data
    ActionCable.server.broadcast("analysis_#{analysis.id}", {
      cookie_system: id
    })
  end
end
