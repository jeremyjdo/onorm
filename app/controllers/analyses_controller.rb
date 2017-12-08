class AnalysesController < ApplicationController
  def index
  end

  def show
    @analysis = Analysis.find(params[:id])
  end

  # Home joue le rôle de new
  # def new
  # end

  def create
    @analysis = Analysis.new(analysis_params)
    if @analysis.save
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

        computing_total_score(@analysis)
        redirect_to analysis_path(@analysis)
    else
      render 'pages/home'
    end
  end

  # private

  def analysis_params
    params.require(:analysis).permit(:website_url)
  end

  def computing_total_score(analysis)

    analysis.identification.score = (analysis.identification.score * 50).round(2)
    analysis.cookie_system.score  = (analysis.cookie_system.score * 50).round(2)
    analysis.total_score = analysis.cookie_system.score + analysis.identification.score
    analysis.save!

  end
end
