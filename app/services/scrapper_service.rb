require 'open-uri'
require 'nokogiri'

class ScrapperService

attr_accessor :cgvu_url, :identification_url, :cookie_system_url, :data_privacy_url

  def initialize

# INSTANCE VARIABLE FOR PRESENCE
    @cgvu_wording_library = ["CONDITIONS GéNéRALES DE VENTES","CGV","SERVICE CLIENTS","RèGLES","CONDITIONS","CGU"]
    @identification_wording_library = ["INFORMATIONS LéGALES","MENTIONS LéGALES"]
    @cookie_system_wording_library = ["COOKIES"]
    @data_privacy_wording_library = ["DONNéES PERSONNELLES","CONFIDENTIALITé"]

    @cgvu_url = ""
    @identification_url = ""
    @cookie_system_url = ""
    @data_privacy_url = ""

# INSTANCE VARIABLE FOR IDENTIFICATION -> LEGAL_FORM
    @identification_legal_form_presence = false
    @identification_legal_form_text = ""

# INSTANCE VARIABLE FOR IDENTIFICATION -> COMPANY_NAME
    #annotation : For the moment, we don't grab the company name - if legal form is present, we extrapolate and we suppose the company name is also present (just before legal form)
    @identification_company_name_presence = false
    @identification_company_name_text = ""

# INSTANCE VARIABLE FOR IDENTIFICATION -> COMPANY_NAME

  end

  def presence(url)
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
  end

  def identification(url)
    html_file = open(url).read
    html_doc = Nokogiri::HTML(html_file)

    identification_legal_form(html_doc)

    puts @identification_company_name_presence
    puts @identification_legal_form_presence
    puts @identification_legal_form_text
  end

  private

  def identification_legal_form(html_doc)
    #IMPROVEMENT - IF NOTHING FOUND, SEARCH ON THE NON_ACRONYME VERSION => Ex : société par actions simplifiée
    #ANNOTATION = Match if we just want the first occurence, scan if we want all the occurence
    #ANNOTATION = We can grab the full sentence by altering the regex code
    raw_target = html_doc.search("body").text.match(/\b(SA|SAS|SARL|SASU|EI|EIRL|EURL|EARL|GAEC|GEIE|GIE|SASU|SC|SCA|SCI|SCIC|SCM|SCOP|SCP|SCS|SEL|SELAFA|SELARL|SELAS|SELCA|SEM|SEML|SEP|SICA|SNC)\b/)
    if raw_target
      @identification_legal_form_text  = raw_target
      @identification_legal_form_presence = true

      @identification_company_name_presence = true
    end
  end

end
