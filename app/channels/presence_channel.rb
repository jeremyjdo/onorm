class PresenceChannel < ApplicationCable::Channel
  def subscribed
    stream_from "presence_for_analysis_#{params[:analysis_id]}"
    PresenceJob.perform_later(params[:analysis_id])
  end
end
