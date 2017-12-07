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
    cookie_system_check(@analysis)

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

  def cookie_system_check(analysis)
    cookie_checker = CookieService.new
    @cookie_system = CookieSystem.new
    @cookie_system.analysis = @analysis
    cookie_checker.cookie_list(analysis.website_url) != {} ? @cookie_system.cookie_usage = true : @cookie_system.cookie_usage = false
    cookie_checker.cookie_banner?(analysis.website_url) ? @cookie_system.cookie_user_agreement = true : @cookie_system.cookie_user_agreement = false
    @cookie_system.save!
  end
end
