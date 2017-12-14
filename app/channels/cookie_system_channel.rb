class CookieSystemChannel < ApplicationCable::Channel
  def subscribed
    stream_from "cookie_system_for_analysis_#{params[:analysis_id]}"
    CookieSystemJob.perform_later(params[:analysis_id])
  end
end
