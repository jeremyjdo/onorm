require 'open-uri'
require 'nokogiri'

class PresenceService

attr_accessor :cgvu_url, :identification_url, :cookie_system_url, :data_privacy_url

  def initialize(analysis)
    @analysis = analysis

    @cgvu_wording_library = ["CONDITIONS GéNéRALES DE VENTES","CGV","SERVICE CLIENTS","RèGLES","CONDITIONS","CGU"]
    @identification_wording_library = ["INFORMATIONS LéGALES","MENTIONS LéGALES"]
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

    @analysis.cgvu_url = @cgvu_url
    @analysis.identification_url = @identification_url
    @analysis.cookie_system_url = @cookie_system_url
    @analysis.data_privacy_url = @data_privacy_url

    unless @analysis.save!
      render "root"
    end
  end
end
