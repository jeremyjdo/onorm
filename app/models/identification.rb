class Identification < ApplicationRecord
  belongs_to :analysis
  # after_create :broadcast_data

  # def broadcast_data
  #   ActionCable.server.broadcast("identification_for_analysis_#{analysis.id}", {
  #     identification_header_partial: ApplicationController.renderer.render(
  #       partial: "analyses/identification_header",
  #       locals: { identification: self, analysis: self.analysis }
  #     ),
  #     identification_panel_partial: ApplicationController.renderer.render(
  #       partial: "analyses/identification_panel",
  #       locals: { analysis: self.analysis },
  #     ),
  #     score_header_partial: ApplicationController.renderer.render(
  #     partial: "analyses/score_header",
  #     locals: { analysis: self.analysis },
  #   })
  # end
end
