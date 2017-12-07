require 'open-uri'
require 'nokogiri'

class IdentificationService

#attr_accessor :identification_address_presence, :identification_address_text, :identification_capital_presence, :identification_capital_text, :identification_legal_form_presence, :identification_legal_form_text, :identification_company_name_presence, :identification_host_text, :identification_host_name_presence, :identification_host_address_presence, :identification_host_phone_presence, :identification_rcs_presence, :identification_rcs_text, :identification_tva_presence, :identification_tva_text, :identification_publication_director_presence, :identification_publication_director_text, :identification_email_presence, :identification_email_text, :identification_phone_presence, :identification_phone_text

  def initialize(analysis)
    @analysis = analysis

    # INSTANCE VARIABLE FOR IDENTIFICATION -> SCORE
        @identification_score = 0.to_f

    # INSTANCE VARIABLE FOR IDENTIFICATION -> LEGAL_FORM
        @identification_legal_form_presence = false
        @identification_legal_form_text = ""

    # INSTANCE VARIABLE FOR IDENTIFICATION -> COMPANY_NAME
        #annotation : For the moment, we don't grab the company name - if legal form is present, we extrapolate and we suppose the company name is also present (just before legal form). To obtain it, we could alter the regex
        @identification_company_name_presence = false
        @identification_company_name_text = ""

    # INSTANCE VARIABLE FOR IDENTIFICATION -> LEGAL ADDRESS
        @identification_address_presence = false
        @identification_address_text  = ""

    # INSTANCE VARIABLE FOR IDENTIFICATION -> SOCIAL CAPITAL
        @identification_capital_presence = false
        @identification_capital_text  = ""

    # INSTANCE VARIABLE FOR IDENTIFICATION -> EMAIL
        @identification_email_presence = false
        @identification_email_text  = ""

    # INSTANCE VARIABLE FOR IDENTIFICATION -> PHONE
        @identification_phone_presence = false
        @identification_phone_text  = ""

    # INSTANCE VARIABLE FOR IDENTIFICATION -> RCS
        @identification_rcs_presence = false
        @identification_rcs_text  = ""

    # INSTANCE VARIABLE FOR IDENTIFICATION -> TVA
        @identification_tva_presence = false
        @identification_tva_text  = ""

    # INSTANCE VARIABLE FOR IDENTIFICATION -> PUBLICATION DIRECTOR
        @identification_publication_director_presence = false
        @identification_publication_director_text  = ""

    # INSTANCE VARIABLE FOR IDENTIFICATION -> HOST
        @identification_host_name_presence = false
        @identification_host_address_presence = false
        @identification_host_phone_presence = false
        @identification_host_text  = ""
  end

  def call
    url = @analysis.identification_url
    html_file = open(url).read
    html_doc = Nokogiri::HTML(html_file)

    identification_legal_form(html_doc) #also identificate company name
    identification_address(html_doc)
    identification_capital(html_doc)
    identification_email(html_doc)
    identification_phone(html_doc)
    identification_rcs(html_doc)
    identification_tva(html_doc)
    identification_publication_director(html_doc)
    identification_host(html_doc)

    identification_scorer

    identification_generator
  end

  private

  def identification_legal_form(html_doc)
    #FUTURE IMPROVEMENT - IF NOTHING FOUND, SEARCH ON THE NON_ACRONYME VERSION => Ex : société par actions simplifiée
    #ANNOTATION = Match if we just want the first occurence, scan if we want all the occurence
    #ANNOTATION = We can grab the full sentence by altering the regex code => ^.*\bSAS\b.*$
    raw_target = html_doc.search("body").text.match(/\b(SA|SAS|SARL|SASU|EI|EIRL|EURL|EARL|GAEC|GEIE|GIE|SASU|SC|SCA|SCI|SCIC|SCM|SCOP|SCP|SCS|SEL|SELAFA|SELARL|SELAS|SELCA|SEM|SEML|SEP|SICA|SNC)\b/)
    if raw_target
      @identification_legal_form_text  = raw_target.to_s
      @identification_legal_form_presence = true

      @identification_company_name_presence = true
    end
  end

  def identification_address(html_doc)
    #ANNOTATION - All possible entry point for regex => http://www.cohesion-territoires.gouv.fr/IMG/pdf/annexe_14-11-25_abreviations_des_noms_de_voie_def.pdf
    raw_target = html_doc.search("body").text.match(/^.*\b(allée|autoroute|avenue|boulevard|butte|carrefour|centre commercial|chaussée|chemin|cité|domaine|faubourg|galerie|gare|impasse|lieu-dit|lotissement|maison|mont|parc|parvis|passage|pavillon|place|pont|quai|quartier|résidence|rond-point|route|rue|ruelle|sentier|square|villa|voie|zone industrielle)\b.*$/i)

    if raw_target
      unless raw_target.to_s.match(/\bBP\b/) #if it's a postal box, it's not okay
        @identification_address_text  = raw_target.to_s
        @identification_address_presence = true
      end
    end
  end

  def identification_capital(html_doc)
    raw_target = html_doc.search("body").text.match(/^.*\bcapital\b.*$/i)

    if raw_target
      @identification_capital_text  = raw_target.to_s
      @identification_capital_presence = true
    end
  end

  def identification_email(html_doc)
    #annotation - AU moment de show les resultats de l'analyse, retester si ca commence par contact. Si pas le cas, conseiller de faire une mail commencant par contact
    raw_target = html_doc.search("body").text.match(/\b\w*@\w*.\w*\b/i)

    if raw_target
      @identification_email_text  = raw_target.to_s
      @identification_email_presence = true
    end
  end

  def identification_phone(html_doc)
    raw_target = html_doc.search("body").text.match(/(\+33 |0|\+33)[1-9]( \d\d|\d\d|.\d\d){4}/)

    if raw_target
      @identification_phone_text  = raw_target.to_s
      @identification_phone_presence = true
    end
  end

  def identification_rcs(html_doc)
    raw_target = html_doc.search("body").text.match(/\b(\d\d\d ){2}(\d\d\d)\b/)

    if raw_target
      @identification_rcs_text  = raw_target.to_s
      @identification_rcs_presence = true
    end
  end

  def identification_tva(html_doc)
    raw_target = html_doc.search("body").text.match(/\b(\w\w )(\d){11}\b/)

    if raw_target
      @identification_tva_text  = raw_target.to_s
      @identification_tva_presence = true
    end
  end

  def identification_publication_director(html_doc)
    raw_target = html_doc.search("body").text.match(/^.*\b(directeur de publication|directeur publication|directeur de la publication|responsable de publication|responsable publication|responsable de la publication)\b.*$/i)

    if raw_target
      @identification_publication_director_text  = raw_target.to_s
      @identification_publication_director_presence = true
    end
  end

  def identification_host(html_doc)
    raw_host = html_doc.search("body").text.match(/^.*\bhébergeur\b.*$/i)

    if raw_host
      @identification_host_text  = raw_host.to_s
      @identification_host_name_presence = true
      identification_host_address(raw_host)
      identification_host_phone(raw_host)
    end
  end

  def identification_host_address(raw_host)
    raw_target = raw_host.to_s.match(/^.*\b(allée|autoroute|avenue|boulevard|butte|carrefour|centre commercial|chaussée|chemin|cité|domaine|faubourg|galerie|gare|impasse|lieu-dit|lotissement|maison|mont|parc|parvis|passage|pavillon|place|pont|quai|quartier|résidence|rond-point|route|rue|ruelle|sentier|square|villa|voie|zone industrielle)\b.*$/i)

    if raw_target
      @identification_host_address_presence = true
    end
  end

  def identification_host_phone(raw_host)
    raw_target = raw_host.to_s.match(/(\+33 |0|\+33)[1-9]( \d\d|\d\d|.\d\d){4}/)

    if raw_target
      @identification_host_phone_presence = true
    end
  end

  def identification_scorer
    # Score is computed to return a float between 0 and 1
    # [factor, coefficient for ponderation] => Just Change integers to alter coefficient
    scorer_table = [
      [@identification_company_name_presence,1],
      [@identification_legal_form_presence,1],
      [@identification_address_presence,1],
      [@identification_capital_presence,1],
      [@identification_email_presence,1],
      [@identification_phone_presence,1],
      [@identification_rcs_presence,1],
      [@identification_tva_presence,1],
      [@identification_publication_director_presence,1],
      [@identification_host_name_presence,1],
      [@identification_host_address_presence,1],
      [@identification_host_phone_presence,1]
    ]

    total_points = 0
    maximum_points = 0

    scorer_table.each do |factor_and_coeff|
      if factor_and_coeff[0] == true
        total_points = total_points + factor_and_coeff[1]
      end
      maximum_points = maximum_points + factor_and_coeff[1]
    end
    if total_points != 0
      @identification_score = total_points.to_f / maximum_points.to_f
    end
  end

  def identification_generator
    identification = Identification.new

    identification.score = @identification_score
    identification.company_name_presence = @identification_company_name_presence
    identification.legal_form_presence = @identification_legal_form_presence
    identification.legal_form_text = @identification_legal_form_text
    identification.address_presence = @identification_address_presence
    identification.address_text = @identification_address_text
    identification.capital_presence = @identification_capital_presence
    identification.capital_text = @identification_capital_text
    identification.email_presence = @identification_email_presence
    identification.email_text = @identification_email_text
    identification.phone_presence = @identification_phone_presence
    identification.phone_text = @identification_phone_text
    identification.rcs_presence = @identification_rcs_presence
    identification.rcs_text = @identification_rcs_text
    identification.tva_presence = @identification_tva_presence
    identification.tva_text = @identification_tva_text
    identification.publication_director_presence = @identification_publication_director_presence
    identification.publication_director_text = @identification_publication_director_text
    identification.host_name_presence = @identification_host_name_presence
    identification.host_address_presence = @identification_host_address_presence
    identification.host_phone_presence = @identification_host_phone_presence
    identification.host_text = @identification_host_text

    identification.analysis = @analysis

    identification.save!
  end
end
