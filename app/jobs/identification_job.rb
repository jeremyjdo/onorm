class IdentificationJob < ApplicationJob
  queue_as :default

  def perform(analysis_id)
    # Do something later
    @analysis = Analysis.find(analysis_id)
    identification_service = IdentificationService.new(@analysis)
    identification_service.call
  end
end
