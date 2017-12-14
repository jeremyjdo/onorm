class ScoreChannel < ApplicationCable::Channel
  def subscribed
    stream_from "score_for_analysis_#{params[:analysis_id]}"
  end
end
