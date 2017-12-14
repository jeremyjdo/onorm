require 'open-uri'
require 'nokogiri'

class CGVUService

  attr_accessor :raw_articles

  def initialize(analysis, brain)
    @analysis = analysis

    @cgvu_score = 0.to_f

    @raw_articles = []

    @brain = brain

#INSTANCE VARIABLE FOR SERVICE GROUP / CLAUSES

    @service_presence = false
    @service_article_ref = ""

      @service_access_presence = false
      @service_access_score = 0

      @service_description_presence = false
      @service_description_score = 0



#INSTANCE VARIABLE FOR DELIVERY GROUP / CLAUSES

    @delivery_presence = false
    @delivery_article_ref = ""

      @delivery_modality_presence = false
      @delivery_modality_score = 0

      @delivery_shipping_presence = false
      @delivery_shipping_score = 0

      @delivery_time_presence = false
      @delivery_time_score = 0


#INSTANCE VARIABLE FOR PRICE GROUP / CLAUSES

    @price_presence = false
    @price_article_ref = ""

      @price_mention_presence = false
      @price_mention_score = 0

      @price_euro_currency_presence = false
      @price_euro_currency_score = 0

      @price_ttc_presence = false
      @price_ttc_score = 0

#INSTANCE VARIABLE FOR PAYMENT GROUP / CLAUSES

    @payment_presence = false
    @payment_article_ref = ""

      @payment_mention_presence = false
      @payment_mention_score = 0

#INSTANCE VARIABLE FOR RETRACTATION GROUP / CLAUSES

    @retractation_presence = false
    @retractation_article_ref = ""

      @retractation_right_presence = false
      @retractation_right_score = 0

#INSTANCE VARIABLE FOR CONTRACT CONCLUSION GROUP / CLAUSES

    @contract_conclusion_presence = false
    @contract_conclusion_article_ref = ""

      @contract_conclusion_modality_presence = false
      @contract_conclusion_modality_score = 0

      @contract_conclusion_human_error_presence = false
      @contract_conclusion_human_error_score = 0

      @contract_conclusion_agreement_presence = false
      @contract_conclusion_agreement_score = 0

    @offer_durability_presence = false
    @offer_durability_article_ref = ""

      @contract_conclusion_offer_durability_presence = false
      @contract_conclusion_offer_durability_score = 0

  #INSTANCE VARIABLE FOR guarantee & SAV GROUP / CLAUSES

    @guaranteeandsav_presence = false
    @guaranteeandsav_article_ref = ""

      @guaranteeandsav_guarantee_presence = false
      @guaranteeandsav_guarantee_score = 0

      @guaranteeandsav_sav_presence = false
      @guaranteeandsav_sav_score = 0

  end

  def call
    url = @analysis.cgvu_url
    html_file = open(url).read
    html_doc = Nokogiri::HTML(html_file)

#Firstly we scrap and parse articles, by using the headers pattern (Article Title)
    scrap_by_header_pattern(html_doc)

    unless @raw_articles.any?
      return #FALLBACK A INTEGRER si aucun article n'a été trouvé. Possible Improvement : Create a another scraper/parser, using for ex the index article table
    end

#Secondly, we run the analysis of the different articles
    articles_analyze

    cgvu_scorer
    cgvu_generator
  end

  private

###############################################################

  def scrap_by_header_pattern(html_doc)
    raw_target = html_doc.at("body").search('h1, h2, h3, h4, h5, h6')
    if raw_target
      raw_target.each_with_index do |header, index|
#We seach with a regex various Article Title Patterns
        if header.text.strip.match(/(article \d+)|(\A\d+)|(\A\d+.)/i)

          raw_article = []
          raw_article << header.text.strip
          raw_article_body = ""
          el = header.next_element

#DON'T TOUCH -> the While block allow us to capture the whole body article and to break at the next identified Header OR when we are iterating on the last article OR when we detect a Article Title Pattern
          while(true) do
            if el.try(:next_element)
              raw_article_body = raw_article_body + el.text
              el = el.next_element
                if el == raw_target[index + 1] || index == raw_target.size - 1 || el.text.strip.match(/(\A\d+ \b)|(\A\d+. \b)/i)
                  break
                end
            elsif el.try(:text)
              raw_article_body = raw_article_body + el.text
              break
            else
              break
            end
          end

          raw_article << raw_article_body
          @raw_articles << raw_article
        end
      end
    end
  end

###############################################################

  def articles_analyze
#We conduct the different steps of the analysis for each article
#Selected Groups is an array which will stock the identified group/clauses for each article. We need to clean it at the end of the iteration, before conducting the next article analysis
    @raw_articles.each do |raw_article|
      @selected_groups = []
      article_identification(raw_article)
      article_evaluation(raw_article)
      @selected_groups = []
    end
  end

  def article_identification(raw_article)
#We send the Article Title To MICROSOFT LANGUAGE UNDERSTANDING INTELLIGENT SYSTEM, to identify entities related to specific groups/clauses
#You have to Train LUIS MODEL. It's possible that iterating on entities is not the best alternative for a post-MVP version. Then, you could refactor it in order to iterate on intents.
    result = @brain.luis(raw_article[0])
    entities = []

    raw_entities = result["entities"]
    raw_entities.each do |raw_entity|
     entities << raw_entity["type"]
    end

#For each detected entities, we stock the key reference of related groups/clauses in @selected_groups + we save the article title in a ref variable + we activate related boolean
    entities.each do |entity|

      if entity == "service"
        @selected_groups << "service"
        @service_article_ref = raw_article[0] if @service_presence == false
        @service_presence = true

      elsif entity == "price"
        @selected_groups << "price"
        @price_article_ref = raw_article[0] if @price_presence == false
        @price_presence = true

      elsif entity == "delivery"
        @selected_groups << "delivery"
        @delivery_article_ref = raw_article[0] if @delivery_presence == false
        @delivery_presence = true

      elsif entity == "payment"
        @selected_groups << "payment"
        @payment_article_ref = raw_article[0] if @payment_presence == false
        @payment_presence = true

      elsif entity == "contract_conclusion"
        @selected_groups << "contract_conclusion"
        @contract_conclusion_article_ref = raw_article[0] if @contract_conclusion_presence == false
        @contract_conclusion_presence = true

      elsif entity == "offer_durability"
        @selected_groups << "offer_durability"
        @offer_durability_article_ref = raw_article[0] if @offer_durability_presence == false
        @offer_durability_presence = true


      elsif entity == "retractation"
        @selected_groups << "retractation"
        @retractation_article_ref = raw_article[0] if @retractation_presence == false
        @retractation_presence = true

      elsif entity == "guaranteeandsav"
        @selected_groups << "guaranteeandsav" #if @guaranteeandsav_presence == false
        @guaranteeandsav_article_ref = raw_article[0] if @guaranteeandsav_presence == false
        @guaranteeandsav_presence = true
      end
    end
  end

  def article_evaluation(raw_article)
  #We send the body article to MICROSOFT TEXT ANALYSIS COGNITIVE SERVICE, in order to extract Key Contents of the Article. (Based on deep semantic relationships)
    article_body = raw_article[1]

    raw_article_key_phrases = @brain.text_analysis(article_body)

    article_key_phrases = raw_article_key_phrases.map { |kp| kp.downcase }

  #We use each group/clause key saved in @selected_groups in order to call the related functions
    @selected_groups.each do |group|

      if group == "service"
        #We test for all the required information of the service group
        cgvu_service_access(article_body, article_key_phrases)
        cgvu_service_description(article_body, article_key_phrases)

      elsif group == "delivery"
        #We test for all the required information of the delivery group
        cgvu_delivery_modality(article_body, article_key_phrases)
        cgvu_delivery_shipping(article_body, article_key_phrases)
        cgvu_delivery_time(article_body, article_key_phrases)

      elsif group == "price"
        #We test for all the required information of the price group
        cgvu_price_mention(article_body, article_key_phrases)
        cgvu_price_euro_currency(article_body, article_key_phrases)
        cgvu_price_ttc(article_body, article_key_phrases)

      elsif group == "payment"
        #We test for all the required information of the payment group
        cgvu_payment_mention(article_body, article_key_phrases)

      elsif group == "contract_conclusion"
        #We test for all the required information of the contract_conclusion group
        cgvu_contract_conclusion_modality(article_body, article_key_phrases)
        cgvu_contract_conclusion_human_error(article_body, article_key_phrases)
        cgvu_contract_conclusion_agreement(article_body, article_key_phrases)

      elsif group == "offer_durability"
        #We test for all the required information of the contract_conclusion group
        cgvu_contract_conclusion_offer_durability(article_body, article_key_phrases)

      elsif group == "retractation"
        #We test for all the required information of the retractation group
        cgvu_retractation_right(article_body, article_key_phrases)

      elsif group == "guaranteeandsav"
        #We test for all the required information of the guaranteeandsav group
        cgvu_guaranteeandsav_guarantee(article_body, article_key_phrases)
        cgvu_guaranteeandsav_sav(article_body, article_key_phrases)
      end

    end
  end

###############################################################

  def cgvu_scorer

#We calculate the global score of CGVU
    scorer_table = [
      @service_access_score,
      @service_description_score,
      @delivery_modality_score,
      @delivery_shipping_score,
      @delivery_time_score,
      @price_ttc_score,
      @price_euro_currency_score,
      @price_mention_score,
      @payment_mention_score,
      @retractation_right_score,
      @contract_conclusion_modality_score,
      @contract_conclusion_human_error_score,
      @contract_conclusion_agreement_score,
      @contract_conclusion_offer_durability_score,
      @guaranteeandsav_guarantee_score,
      @guaranteeandsav_sav_score
    ]

    total_points = 0.to_f
    maximum_points = 0

    scorer_table.each do |factor|

        factor = 1 if factor > 1
        total_points = total_points + factor.to_f

      maximum_points = maximum_points + 1
    end
    if total_points != 0
      @cgvu_score = total_points.to_f / maximum_points.to_f
    end

    @cgvu_score = (@cgvu_score * 40)
  end

  def cgvu_generator
#We generate the CGVU instance and save it to the Analysis object
    cgvu = Cgvu.new

    cgvu.score = @cgvu_score

    cgvu.service_presence = @service_presence
    cgvu.service_article_ref = @service_article_ref
    cgvu.service_access_presence = @service_access_presence
    cgvu.service_description_presence = @service_description_presence

    cgvu.delivery_presence = @delivery_presence
    cgvu.delivery_article_ref = @delivery_article_ref
    cgvu.delivery_modality_presence = @delivery_modality_presence
    cgvu.delivery_shipping_presence = @delivery_shipping_presence
    cgvu.delivery_time_presence = @delivery_time_presence

    cgvu.price_presence = @price_presence
    cgvu.price_article_ref = @price_article_ref
    cgvu.price_euro_currency_presence = @price_euro_currency_presence
    cgvu.price_ttc_presence = @price_ttc_presence
    cgvu.price_mention_presence = @price_mention_presence

    cgvu.payment_presence = @payment_presence
    cgvu.payment_article_ref = @payment_article_ref
    cgvu.payment_mention_presence = @payment_mention_presence

    cgvu.retractation_presence = @retractation_presence
    cgvu.retractation_article_ref = @retractation_article_ref
    cgvu.retractation_right_presence = @retractation_right_presence

    cgvu.contract_conclusion_presence = @contract_conclusion_presence
    cgvu.contract_conclusion_article_ref = @contract_conclusion_article_ref
    cgvu.contract_conclusion_modality_presence = @contract_conclusion_modality_presence
    cgvu.contract_conclusion_agreement_presence = @contract_conclusion_agreement_presence
    cgvu.contract_conclusion_human_error_presence = @contract_conclusion_human_error_presence
    cgvu.contract_conclusion_offer_durability_presence = @contract_conclusion_offer_durability_presence

    cgvu.offer_durability_presence = @offer_durability_presence
    cgvu.offer_durability_article_ref = @offer_durability_article_ref
    cgvu.guaranteeandsav_presence = @guaranteeandsav_presence
    cgvu.guaranteeandsav_article_ref = @guaranteeandsav_article_ref
    cgvu.guaranteeandsav_guarantee_presence = @guaranteeandsav_guarantee_presence
    cgvu.guaranteeandsav_sav_presence = @guaranteeandsav_presence

    cgvu.analysis = @analysis

    cgvu.save!

    @analysis.calculate_score

    ActionCable.server.broadcast("cgvu_for_analysis_#{@analysis.id}", {
      cgvu_header_partial: ApplicationController.renderer.render(
        partial: "analyses/cgvu_header",
        locals: { analysis: @analysis }
      ),
      cgvu_panel_partial: ApplicationController.renderer.render(
        partial: "analyses/cgvu_panel",
        locals: { analysis: @analysis },
      ),
      score_header_partial: ApplicationController.renderer.render(
        partial: "analyses/score_header",
        locals: { analysis: @analysis },
      )
    })
  end

###############################################################
###############################################################
#METHODS FOR REQUIRED INFORMATION IDENTIFICATION
#For most of the following methods :
#1. We try to detect the required information in the Key Phrases of the Article, extracted by Text Analysis
# => If we have a match, we save its presence and we attribute the maximum score. (Deep semantic relationships => ++ probability of a coherent concept and ++ probability of a reader-friendly article)
#2. If the first try has no result, we reconduct the test with the whole Article
# => If we have a match, we save its presence and we attribute a score with a penalty. (No Deep semantic relationships => -- probability of a coherent concept and -- probability of a reader-friendly article)
#For some other methods :
#Because the evaluation is based on complex syntaxic pattern, we combinate each of us : 1/3 of points if present in KeyPhrases + 2/3 if present in body article
###############################################################
#SERVICE
#LUIS - PREAMBULE OBJET GENERAL
  def cgvu_service_access(article_body, article_key_phrases)
    #We firstly test on the article_key_phrases => Score maximized
    raw_target = article_key_phrases.join(" ").match(/(?=.*accès)(?=.*service).*|/i)

    if raw_target
      @service_access_score  = @service_access_score + 0.30.to_f
      @service_access_presence = true
    end
      #We give it a second try on the whole body of the article => Score minimized
    raw_target = article_body.match(/(?=.*société)(?=.*access)(?=.*édit).*|(?=.*société)(?=.*accè)(?=.*édit).*|(?=.*société)(?=.*access)(?=.*propos).*|(?=.*société)(?=.*accè)(?=.*propos).*/i)
    if raw_target
      @service_access_score = @service_access_score + 0.70.to_f
      @service_access_presence = true
    end
  end

  def cgvu_service_description(article_body, article_key_phrases)
    #We firstly test on the article_key_phrases => Score maximized
    raw_target = article_key_phrases.join(" ").match(/#REGEX/)

    if raw_target
      @service_description_score  = 1.to_f
      @service_description_presence = true
    else
      #We give it a second try on the whole body of the article => Score minimized
      raw_target = article_body.match(/(?=.*desti)(?=.*permet)(?=.*à)(?=.*\bde\b).*|(?=.*desti)(?=.*permet)(?=.*à)(?=.*\bdes\b).*|(?=.*propos)(?=.*permet)(?=.*à)(?=.*\bde\b).*|(?=.*propos)(?=.*permet)(?=.*à)(?=.*\bdes\b).*/i)

      if raw_target
      @service_description_score = 0.66.to_f
      @service_description_presence = true
      end
    end
  end

###############################################################
#DELIVERY

  def cgvu_delivery_modality(article_body, article_key_phrases)
    #Article 5 - Livraison  ARTICLE 5 – MODALITES DE LIVRAISON
    #We firstly test on the article_key_phrases => Score maximized
    raw_target = article_key_phrases.join(" ").match(/(?=.*modalité de livraison).*|(?=.*mode de livraison).*/i)

    if raw_target
      @delivery_modality_score  = 1.to_f
      @delivery_modality_presence = true
    else
      #We give it a second try on the whole body of the article => Score minimized
      raw_target = article_body.match(/(?=.*modalité de livraison).*|(?=.*mode de livraison).*|(?=.*livré à).*|(?=.*livrés à).*/i)

      if raw_target
      @delivery_modality_score = 0.66.to_f
      @delivery_modality_presence = true
      end
    end
  end

  def cgvu_delivery_shipping(article_body, article_key_phrases)
    #We firstly test on the article_key_phrases => Score maximized
    raw_target = article_key_phrases.join(" ").match(/(?=.*frais de livraison).*|(?=.*frais d'expédition).*/i)

    if raw_target
      @delivery_shipping_score  = 1.to_f
      @delivery_shipping_presence = true
    else
      #We give it a second try on the whole body of the article => Score minimized
      raw_target = article_body.match(/(?=.*frais de livraison).*|(?=.*frais d'expédition).*/i)

      if raw_target
      @delivery_shipping_score = 0.66.to_f
      @delivery_shipping_presence = true
      end
    end
  end

  def cgvu_delivery_time(article_body, article_key_phrases)
    #We firstly test on the article_key_phrases => Score maximized
    raw_target = article_key_phrases.join(" ").match(/(?=.*délai).*(?=.*livraison)(?=.*\d+).*/i)

    if raw_target
      @delivery_delivery_score  = 1.to_f
      @delivery_delivery_presence = true
    else
      #We give it a second try on the whole body of the article => Score minimized
      raw_target = article_body.match(/(?=.*délai).*(?=.*livraison)(?=.*\d+).*/i)

      if raw_target
      @delivery_time_score = 0.66.to_f
      @delivery_time_presence = true
      end
    end
  end

###############################################################
#PRICE

  def cgvu_price_mention(article_body, article_key_phrases)
    #We firstly test on the article_key_phrases => Score maximized
    raw_target = article_key_phrases.join(" ").match(/^.*\bprix\b.*$/i)

    if raw_target
      @price_mention_score  = 1.to_f
      @price_mention_presence = true
    else
      #We give it a second try on the whole body of the article => Score minimized
      raw_target = article_body.match(/^.*\bprix\b.*$/i)

      if raw_target
      @price_mention_score = 0.66.to_f
      @price_mention_presence = true
      end
    end
  end

  def cgvu_price_euro_currency(article_body, article_key_phrases)
    #We firstly test on the article_key_phrases => Score maximized
    raw_target = article_key_phrases.join(" ").match(/^.*\b(euros)|(euro)|(€)\b.*$/i)

    if raw_target
      @price_euro_currency_score  = 1.to_f
      @price_euro_currency_presence = true
    else
      #We give it a second try on the whole body of the article => Score minimized
      raw_target = article_body.match(/^.*\b(euros)|(euro)|(€)\b.*$/i)

      if raw_target
      @price_euro_currency_score = 0.66.to_f
      @price_euro_currency_presence = true
      end
    end
  end

  def cgvu_price_ttc(article_body, article_key_phrases)
    #We firstly test on the article_key_phrases => Score maximized
    raw_target = article_key_phrases.join(" ").match(/^.*\b(toutes taxes comprises)|(TVA)\b.*$/i)

    if raw_target
      @price_ttc_score  = 1.to_f
      @price_ttc_presence = true
    else
      #We give it a second try on the whole body of the article => Score minimized
      raw_target = article_body.match(/^.*\b(toutes taxes comprises)|(TVA)\b.*$/i)

      if raw_target
      @price_ttc_score = 0.66.to_f
      @price_ttc_presence = true
      end
    end
  end

###############################################################
#PAYMENT
#LUIS -     #Paiement, Modalités de paiement, Modalités de paiement et de reversement,Article 6 - Paiement, Paiement et facturation,
  def cgvu_payment_mention(article_body, article_key_phrases)
    #We firstly test on the article_key_phrases => Score maximized
    raw_target = article_key_phrases.join(" ").match(/(?=.*modalités)(?=.*paiement).*|(?=.*conditions)(?=.*paiement).*/i)

    if raw_target
      @payment_mention_score  = 1.to_f
      @payment_mention_presence = true
    else
      #We give it a second try on the whole body of the article => Score minimized
      raw_target = article_body.match(/(?=.*obligation)(?=.*règlement)(?=.*moyen)(?=.*accepté).*|(?=.*obligation)(?=.*paiement)(?=.*moyen)(?=.*accepté).*|(?=.*paiement)(?=.*exigible).*|(?=.*mandat)(?=.*encaissement).*|(?=.*modalités)(?=.*paiement).*|(?=.*conditions)(?=.*paiement).*/i)

      if raw_target
      @payment_mention_score = 0.66.to_f
      @payment_mention_presence = true
      end
    end
  end

###############################################################
#CONTRACT CONCLUSION

  def cgvu_contract_conclusion_modality(article_body, article_key_phrases)
    # Article 2 - Commande,   Validation de votre commande,   réservation
    #We firstly test on the article_key_phrases => Score maximized
    raw_target = article_key_phrases.join(" ").match(/(?=.*commande)(?=.*pass).*|(?=.*commande)(?=.*effect).*/i)

    if raw_target
      @contract_conclusion_modality_score  = @contract_conclusion_modality_score + 0.30.to_f
      @contract_conclusion_modality_presence = true
    end
      #We give it a second try on the whole body of the article => Score minimized
    raw_target = article_body.match(/(?=.*pouvez passer commande).*|(?=.*peut passer commande).*|(?=.*peut effectuer).*|(?=.*pouvez effectuer).*/i)

    if raw_target
      @contract_conclusion_modality_score  = @contract_conclusion_modality_score + 0.70.to_f
      @contract_conclusion_modality_presence = true
    end
  end

  def cgvu_contract_conclusion_offer_durability(article_body, article_key_phrases)
    #We firstly test on the article_key_phrases => Score maximized
    #Article 4 - Disponibilité
    raw_target = article_key_phrases.join(" ").match(/#REGEX/)

    if raw_target
      @contract_conclusion_offer_durability_score  = 1.to_f
      @contract_conclusion_offer_durability_presence = true
    else
      #We give it a second try on the whole body of the article => Score minimized
      raw_target = article_body.match(/(?=.*offre)(?=.*valable)(?=.*tant).*|(?=.*offre)(?=.*valable)(?=.*jusqu).*/i)

      if raw_target
      @contract_conclusion_offer_durability_score = 1.to_f
      @contract_conclusion_offer_durability_presence = true
      end
    end
  end

  def cgvu_contract_conclusion_human_error(article_body, article_key_phrases)
    #We firstly test on the article_key_phrases => Score maximized
    raw_target = article_key_phrases.join(" ").match(/(?=.*commande)(?=.*information)(?=.*contractuelle).*/i)

    if raw_target
      @contract_conclusion_human_error_score  = @contract_conclusion_human_error_score + 0.30.to_f
      @contract_conclusion_human_error_presence = true
    end
      #We give it a second try on the whole body of the article => Score minimized
      raw_target = article_body.match(/(?=.*information)(?=.*contract)(?=.*confirm).*/i)

    if raw_target
      @contract_conclusion_human_error_score = @contract_conclusion_human_error_score + 0.70.to_f
      @contract_conclusion_human_error_presence = true
    end
  end

  def cgvu_contract_conclusion_agreement(article_body, article_key_phrases)
    #We firstly test on the article_key_phrases => Score maximized
    raw_target = article_key_phrases.join(" ").match(/(?=.*commande)(?=.*accept).*|(?=.*commande)(?=.*confirm).*/i)

    if raw_target
      @contract_conclusion_agreement_score  = 1.to_f
      @contract_conclusion_agreement_presence = true
    else
      #We give it a second try on the whole body of the article => Score minimized
      raw_target = article_body.match(/(?=.*accept)(?=.*CGV).*|(?=.*accept)(?=.*Conditions Générales).*|(?=.*accept)(?=.*contrat).*|(?=.*accept)(?=.*contract).*/i)

      if raw_target
      @contract_conclusion_agreement_score = 0.66.to_f
      @contract_conclusion_agreement_presence = true
      end
    end
  end

###############################################################
#RETRACTATION

  def cgvu_retractation_right(article_body, article_key_phrases)
    #Article 8 - Droit de rétractation  Politique d’annulation - Obligation de l'offreur

    #We firstly test on the article_key_phrases => Score maximized
    raw_target = article_key_phrases.join(" ").match(/#REGEX/)

    if raw_target
      @retractation_right_score  = 1.to_f
      @retractation_right_presence = true
    else
      #We give it a second try on the whole body of the article => Score minimized
      raw_target = article_body.match(/(?=.*délai)(?=.*légal)(?=.*\d+)(?=.*droit)(?=.*rétract)(?=.*modalités).*|(?=.*délai)(?=.*légal)(?=.*\d+)(?=.*droit)(?=.*rétract)(?=.*conditions).*|(?=.*en cas)(?=.*rétract)(?=.*\d+)(?=.*rembourse).*|(?=.*annul)(?=.*rétract)(?=.*\d+)(?=.*droit).*|(?=.*renonce)(?=.*rétract)(?=.*délai).*/i)

      if raw_target
      @retractation_right_score = 1.to_f
      @retractation_right_presence = true
      end
    end
  end

###############################################################
#guarantee AND SAV

  def cgvu_guaranteeandsav_guarantee(article_body, article_key_phrases)
    # Article 9 - Garanties, Article 10 - Service clientèle, Assistance, 8. RECLAMATIONS, DROIT DE RETRACTATION ET GARANTIES,
    #We firstly test on the article_key_phrases => Score maximized
    raw_target = article_key_phrases.join(" ").match(/#REGEX/)

    if raw_target
      @guaranteeandsav_guarantee_score  = 1.to_f
      @guaranteeandsav_guarantee_presence = true
    else
      #We give it a second try on the whole body of the article => Score minimized
      raw_target = article_body.match(/(?=.*garantie)(?=.*conformité).*/i)

      if raw_target
      @guaranteeandsav_guarantee_score = 0.66.to_f
      @guaranteeandsav_guarantee_presence = true
      end
    end
  end

  def cgvu_guaranteeandsav_sav(article_body, article_key_phrases)
    #We firstly test on the article_key_phrases => Score maximized
    raw_target = article_key_phrases.join(" ").match(/#REGEX/)

    if raw_target
      @guaranteeandsav_guarantee_score  = 1.to_f
      @guaranteeandsav_guarantee_presence = true
    else
      #We give it a second try on the whole body of the article => Score minimized
      raw_target = article_body.match(/(?=.*\bSAV\b).*|(?=.*service client)(?=.*contact).*|(?=.*assistance)(?=.*contact).*/i)

      if raw_target
      @guaranteeandsav_guarantee_score = 0.66.to_f
      @guaranteeandsav_guarantee_presence = true
      end
    end
  end
end


###############################################################
#TUTORIAL - QUICKLY INTEGRATE A NEW CLAUSE
#TR -> To Replace
#Add the following code to the entities Enumerable (article_identification). (the LUIS entity should have the same name as the group/clause name)
#
# if entity == "TRgroupname"
#         @selected_groups << "TRgroupname" if @TRgroupname_presence == false
#         @TRgroupname_article_ref = raw_article[0] if @TRgroupname_presence == false
#         @TRgroupname_presence = true
#
#
#
#
#Add the following code to the selected_groups Enumerable (article_evaluation)
#
# elsif group == "TRgroupname"
#         cgvu_TRgroupname_TRrequiredfirstinformationname(article_body, article_key_phrases)
#         cgvu_TRgroupname_TRrequiredsecondinformationname(article_body, article_key_phrases)
#         cgvu_TRgroupname_TRrequiredthirdinformationname(article_body, article_key_phrases)
#         ....
#
#
#
#
#Then, create the method for each required information, with the following template
#
# def cgvu_TRgroupname_TRrequiredinformationname(article_body, article_key_phrases)
#     raw_target = article_key_phrases.join(" ").match(/#TRREGEXformatchingtherequiredinformation/)
#
#     if raw_target
#       @TRgroupname_TRrequiredinformationname_score  = 1.to_f
#       @TRgroupname_TRrequiredinformationname_presence = true
#     else
#
#       raw_target = article_body.match(/#TRREGEXformatchingtherequiredinformation/)
#
#       if raw_target
#       @TRgroupname_TRrequiredinformationname_score  = 0.66.to_f
#       @TRgroupname_TRrequiredinformationname_presence = true
#       end
#     end
#   end
#
#
#
#Finally, Add those new variables to initialize, cgvu_scorer and cgvu_generator
#Don't forget to train LUIS
#Enjoy !!!!!










