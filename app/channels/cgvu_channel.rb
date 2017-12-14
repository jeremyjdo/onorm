class CgvuChannel < ApplicationCable::Channel
  def subscribed
    stream_from "cgvu_for_analysis_#{params[:analysis_id]}"
  end
end
