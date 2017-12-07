class AnalysesController < ApplicationController
  def index
  end

  def show
    @analysis = Analysis.find(params[:id])
  end

  # Home joue le rôle de new
  def new

  end

  def create
    @analysis = Analysis.new(analysis_params)
    presence_service = PresenceService.new(@analysis)

    presence_service.call

  #Checks if cookies are present
    cookie_service = CookieService.new(@analysis)
    cookie_service.call

  #Run Identification Analysis if identification_url is present
    if @analysis.identification_url != ""
      identification_service = IdentificationService.new(@analysis)
      identification_service.call
    end


  #Final checkup
    if @analysis.save!
      redirect_to analysis_path(@analysis)
    else
      render "root"
    end
  end

  private

  def analysis_params
    params.require(:analysis).permit(:website_url)
  end
end
