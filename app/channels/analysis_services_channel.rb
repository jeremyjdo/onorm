class AnalysisServicesChannel < ApplicationCable::Channel
  def subscribed
    stream_from "analysis_#{params[:analysis_id]}"
  end
end
