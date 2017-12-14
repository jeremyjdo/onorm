class ScoreJob < ApplicationJob
  queue_as :default

  def perform(analysis_id)
    # Do something later

    @analysis = Analysis.find(analysis_id)

    @analysis.total_score = 0
    if @analysis.cookie_system != nil
      @analysis.total_score = @analysis.total_score + @analysis.cookie_system.score
    end
    if @analysis.identification != nil
      @analysis.total_score = @analysis.total_score + @analysis.identification.score
    end
    if @analysis.cgvu != nil
      @analysis.total_score = analysis.total_score + @analysis.cgvu.score
    end

    @analysis.save!

    ActionCable.server.broadcast("score_for_analysis_#{@analysis.id}", {
      score_header_partial: ApplicationController.renderer.render(
        partial: "analyses/score_header",
        locals: { analysis: @analysis }
      )
    })
  end
end
