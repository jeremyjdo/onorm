class PresenceJob < ApplicationJob
  queue_as :default

  def perform(analysis_id)
    # Do something later
    @analysis = Analysis.find(analysis_id)
    presence_service = PresenceService.new(@analysis)
    presence_service.call
  end
end
