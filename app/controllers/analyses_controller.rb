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
    scrapper = ScrapperService.new

    #Scraps URL
    scrapper.presence(@analysis.website_url)
    @analysis.cgvu_url = scrapper.cgvu_url
    @analysis.identification_url = scrapper.identification_url
    @analysis.data_privacy_url = scrapper.data_privacy_url
    @analysis.cookie_system_url = scrapper.cookie_system_url

    if @analysis.save!
      #Checks if cookies are present
      cookie_system_check(@analysis)

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
    cookie_checker = cookieService.new
    cookies = cookie_checker.cookie_list
    @cookie_system = CookieSystem.new
    cookie_list != {} ? @cookie_system.cookie_usage = true : @cookie_system.cookie_usage = false
    cookie_banner? ? @cookie_system.cookie_user_agreement = true : @cookie_system.cookie_user_agreement = false
    @cookie_system.save!
  end
end
