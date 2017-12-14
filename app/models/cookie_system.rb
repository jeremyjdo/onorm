class CookieSystem < ApplicationRecord
  belongs_to :analysis
  # after_create :broadcast_data

  # def broadcast_data
  #   ActionCable.server.broadcast("cookie_system_for_analysis_#{analysis.id}", {
  #     cookie_header_partial: ApplicationController.renderer.render(
  #       partial: "analyses/cookie_header",
  #       locals: { cookie_system: self }
  #     ),
  #     cookie_panel_partial: ApplicationController.renderer.render(
  #       partial: "analyses/cookie_panel",
  #       locals: { analysis: self.analysis },
  #     ),
  #     score_header_partial: ApplicationController.renderer.render(
  #     partial: "analyses/score_header",
  #     locals: { analysis: self.analysis },
  #   })
  # end
end
