class CookieSystemChannel < ApplicationCable::Channel
  def subscribed
    # analysis id ??
    stream_from "cookie_system_for_analysis_#{params[:analysis_id]}"
  end
end
