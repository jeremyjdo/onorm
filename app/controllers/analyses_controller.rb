class AnalysesController < ApplicationController
  def index
  end

  def show
    @analysis = Analysis.find(params[:id])
     respond_to do |format|
      format.html
      format.pdf do
        render pdf: "analysis", layout: "pdf"  # Excluding ".pdf" extension.

      end
    end
  end

  # def show_test

  # end

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

        @analysis.total_score = 0
        if @analysis.cookie_system != nil
          @analysis.total_score = @analysis.total_score + @analysis.cookie_system.score
        end
        if @analysis.identification != nil
          @analysis.total_score = @analysis.total_score + @analysis.identification.score
        end

          @analysis.save!
        redirect_to analysis_path(@analysis)
    else
      render 'pages/home'
    end
  end

  private

  def analysis_params
    params.require(:analysis).permit(:website_url)
  end
end
