class CgvuJob < ApplicationJob
  queue_as :default

  def perform(analysis_id)
    # Do something later
    @analysis = Analysis.find(analysis_id)
    @cognitive_service = CognitiveService.new
    puts ""
    puts ""
    puts ""
    puts ""
    puts ""
    puts ""
    puts ""
    puts "----------------------------------"
    puts @cognitive_service
    puts @analysis
    puts analysis_id
    cgvu_service = CGVUService.new(@analysis, @cognitive_service)
    puts cgvu_service
    cgvu_service.call
  end
end
