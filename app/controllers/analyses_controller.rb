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
    scrapper.presence(@analysis.website_url)
    @analysis.cgvu_url = scrapper.cgvu_url
    @analysis.identification_url = scrapper.identification_url
    @analysis.data_privacy_url = scrapper.data_privacy_url
    @analysis.cookie_system_url = scrapper.cookie_system_url

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
