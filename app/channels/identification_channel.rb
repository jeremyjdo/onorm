class IdentificationChannel < ApplicationCable::Channel
  def subscribed
    stream_from "identification_for_analysis_#{params[:analysis_id]}"
  end
end
