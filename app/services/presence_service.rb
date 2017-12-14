require 'open-uri'
require 'nokogiri'

class PresenceService

attr_accessor :cgvu_url, :identification_url, :cookie_system_url, :data_privacy_url

  def initialize(analysis)
    @analysis = analysis

    @cgvu_wording_library = ["CONDITIONS GéNéRALES DE VENTES","CONDITIONS GéNéRALES","CONDITIONS","CGV","SERVICE CLIENTS","RèGLES","CONDITIONS","CGU","C.G.V","C.G.U"]
    @identification_wording_library = ["INFORMATIONS LéGALES","MENTIONS LéGALES","MENTION LéGALE"]
    @cookie_system_wording_library = ["COOKIES"]
    @data_privacy_wording_library = ["DONNéES PERSONNELLES","CONFIDENTIALITé"]

    @cgvu_url = ""
    @identification_url = ""
    @cookie_system_url = ""
    @data_privacy_url = ""
  end

  def call
    url = @analysis.website_url
    html_file = open(url).read
    html_doc = Nokogiri::HTML(html_file)
    url = url.chomp("/")

    html_doc.css('a').each do |target|
      wording = target.text.strip.upcase
      target_url = target.attribute('href').value
      target_url = url + target_url if target_url.first == "/"
      if @cgvu_wording_library.include?(wording)
          puts @cgvu_url = target_url
      elsif @identification_wording_library.include?(wording)
          puts @identification_url = target_url
      elsif @cookie_system_wording_library.include?(wording)
          puts @cookie_system_url = target_url
      elsif @data_privacy_wording_library.include?(wording)
          puts @data_privacy_url = target_url
      end
    end

    @cgvu_url = @identification_url if @cgvu_url == ""
    @identification_url = @cgvu_url if @identification_url == ""
    @cookie_system_url = @cgvu_url if @cookie_system_url == ""
    @data_privacy_url = @cgvu_url if @data_privacy_url == ""

    @analysis.cgvu_url = @cgvu_url
    @analysis.identification_url = @identification_url
    @analysis.cookie_system_url = @cookie_system_url
    @analysis.data_privacy_url = @data_privacy_url

    #Run Identification Analysis if identification_url is present

    unless @analysis.save!
      render "root"
    end

    # Must be after the analysis save
    if @analysis.identification_url != ""
      IdentificationJob.perform_later(@analysis.id)
    else
      i = Identification.new
      i.score = 0
      i.analysis = @analysis
      i.save!
    end

    # if @analysis.cgvu_url != ""
    # #  IdentificationJob.perform_later(@analysis.id)
    # else
    #   c = Cgvu.new
    #   c.score = 0
    #   c.analysis = @analysis
    #   c.save!
    # end


    # Identification cable test
    # ActionCable.server.broadcast("presence_for_analysis_#{@analysis.id}", {
    #   identification_url: @analysis.identification_url
    # })
  end
end
