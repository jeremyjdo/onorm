class CookieSystemJob < ApplicationJob
  queue_as :default

  def perform(analysis_id)
    # Do something later
    @analysis = Analysis.find(analysis_id)
    cookie_service = CookieService.new(@analysis)
    cookie_service.call
  end
end
