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

  # Home joue le rôle de new
  # def new
  # end

  def create
    @analysis = Analysis.new(analysis_params)
    if @analysis.save
      # MOST JOBS ARE STARTED IN THEIR RESPECTIVE CHANNELS
      # SOME JOBS ARE STARTED in the Presence Service because of dependencies

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
