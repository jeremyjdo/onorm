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

    scrap_by_header_pattern(html_doc)

    unless @raw_articles.any?
      return #FALLBACK A INTEGRER
    end

    articles_analyze
    binding.pry
    cgvu_scorer
    cgvu_generator

  end

  #private

###############################################################

  def scrap_by_header_pattern(html_doc)
    raw_target = html_doc.at("body").search('h1, h2, h3, h4, h5, h6')
    if raw_target
      raw_target.each_with_index do |header, index|
        if header.text.strip.match(/(article \d+\b)|(\A\d+ \b)|(\A\d+. \b)/i)

          raw_article = []
          raw_article << header.text.strip
          raw_article_body = ""
          el = header.next_element

          while(true) do
            if el.try(:next_element)
              raw_article_body = raw_article_body + el.text
              el = el.next_element
                if el == raw_target[index + 1] || index == raw_target.size - 1 || el.text.strip.match(/(\A\d+ \b)|(\A\d+. \b)/i)
                  break
                end
            else
              raw_article_body = raw_article_body + el.text
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
    @raw_articles.each do |raw_article|
      @selected_groups = []
      article_identification(raw_article)
      article_evaluation(raw_article)
      @selected_groups = []
    end
  end

  def article_identification(raw_article)
    result = @brain.luis(raw_article[0])
    entities = result["entities"]
    entities.each do |entity|

      if entity = "service"
        @selected_groups << "service" if @service_presence == false
        @service_article_ref = raw_article[0] if @service_presence == false
        @service_presence = true

      elsif entity = "price"
        @selected_groups << "price" if @price_presence == false
        @price_article_ref = raw_article[0] if @price_presence == false
        @price_presence = true

      elsif entity = "delivery"
        @selected_groups << "delivery" if @delivery_presence == false
        @delivery_article_ref = raw_article[0] if @delivery_presence == false
        @delivery_presence = true

      elsif entity = "payment"
        @selected_groups << "payment" if @payment_presence == false
        @payment_article_ref = raw_article[0] if @payment_presence == false
        @payment_presence = true

      elsif entity = "contract_conclusion"
        @selected_groups << "contract_conclusion" if @contract_conclusion_presence == false
        @contract_conclusion_article_ref = raw_article[0] if @contract_conclusion_presence == false
        @contract_conclusion_presence = true

      elsif entity = "retractation"
        @selected_groups << "retractation" if @retractation_presence == false
        @retractation_article_ref = raw_article[0] if @retractation_presence == false
        @retractation_presence = true

      elsif entity = "guaranteeandsav"
        @selected_groups << "guaranteeandsav" if @guaranteeandsav_presence == false
        @guaranteeandsav_article_ref = raw_article[0] if @guaranteeandsav_presence == false
        @guaranteeandsav_presence = true
      end
    end
  end

  def article_evaluation(raw_article)
    article_body = raw_article[1]

    raw_article_key_phrases = @brain.text_analysis(article_body)

    article_key_phrases = raw_article_key_phrases.map { |kp| kp.downcase }

    @selected_groups.each do |group|

      if group = "service"
        #We test for all the required information of the service group
        cgvu_service_access(article_body, article_key_phrases)
        cgvu_service_description(article_body, article_key_phrases)

      elsif group = "delivery"
        #We test for all the required information of the delivery group
        cgvu_delivery_modality(article_body, article_key_phrases)
        cgvu_delivery_shipping(article_body, article_key_phrases)
        cgvu_delivery_time(article_body, article_key_phrases)

      elsif group = "price"
        #We test for all the required information of the price group
        cgvu_price_mention(article_body, article_key_phrases)
        cgvu_price_euro_currency(article_body, article_key_phrases)
        cgvu_price_ttc(article_body, article_key_phrases)

      elsif group = "payment"
        #We test for all the required information of the payment group
        cgvu_payment_mention(article_body, article_key_phrases)

      elsif group = "contract_conslusion"
        #We test for all the required information of the contract_conslusion group
        cgvu_contract_conslusion_modality(article_body, article_key_phrases)
        cgvu_contract_conslusion_human_error(article_body, article_key_phrases)
        cgvu_contract_conslusion_agreement(article_body, article_key_phrases)
        cgvu_contract_conslusion_offer_durability(article_body, article_key_phrases)

      elsif group = "retractation"
        #We test for all the required information of the retractation group
        cgvu_retractation_right(article_body, article_key_phrases)

      elsif group = "guaranteeandsav"
        #We test for all the required information of the guaranteeandsav group
        cgvu_guaranteeandsav_guarantee(article_body, article_key_phrases)
        cgvu_guaranteeandsav_sav(article_body, article_key_phrases)
      end

    end
  end

###############################################################

  def cgvu_scorer

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

        total_points = total_points + factor.to_f

      maximum_points = maximum_points + 1
    end
    if total_points != 0
      @cgvu_score = total_points.to_f / maximum_points.to_f
    end

    binding.pry
    @cgvu_score = (@cgvu_score * 25)
  end

  def cgvu_generator
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

    cgvu.guaranteeandsav_presence = @guaranteeandsav_presence
    cgvu.guaranteeandsav_article_ref = @guaranteeandsav_article_ref
    cgvu.guaranteeandsav_guarantee_presence = @guaranteeandsav_guarantee_presence
    cgvu.guaranteeandsav_sav_presence = @guaranteeandsav_presence

    cgvu.analysis = @analysis

    binding.pry
    cgvu.save!
  end

###############################################################
###############################################################
###############################################################
#SERVICE

  def cgvu_service_access(article_body, article_key_phrases)
    #We firstly test on the article_key_phrases => Score maximized
    raw_target = article_key_phrases.join(" ").match(/^.*\b(service)|(services)\b.*$/)

    if raw_target
      @service_access_score  = 1.to_f
      @service_access_presence = true
    else
      #We give it a second try on the whole body of the article => Score minimized
      raw_target = article_body.match(/^.*\bservice\b.*$/)
      if raw_target
      @service_access_score = 0.66.to_f
      @service_access_presence = true
      end
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
      raw_target = article_body.match(/#REGEX/)

      if raw_target
      @service_description_score = 0.66.to_f
      @service_description_presence = true
      end
    end
  end

###############################################################
#DELIVERY

  def cgvu_delivery_modality(article_body, article_key_phrases)
    #We firstly test on the article_key_phrases => Score maximized
    raw_target = article_key_phrases.join(" ").match(/#REGEX/)

    if raw_target
      @delivery_modality_score  = 1.to_f
      @delivery_modality_presence = true
    else
      #We give it a second try on the whole body of the article => Score minimized
      raw_target = article_body.match(/#REGEX/)

      if raw_target
      @delivery_modality_score = 0.66.to_f
      @delivery_modality_presence = true
      end
    end
  end

  def cgvu_delivery_shipping(article_body, article_key_phrases)
    #We firstly test on the article_key_phrases => Score maximized
    raw_target = article_key_phrases.join(" ").match(/#REGEX/)

    if raw_target
      @delivery_shipping_score  = 1.to_f
      @delivery_shipping_presence = true
    else
      #We give it a second try on the whole body of the article => Score minimized
      raw_target = article_body.match(/#REGEX/)

      if raw_target
      @delivery_shipping_score = 0.66.to_f
      @delivery_shipping_presence = true
      end
    end
  end

  def cgvu_delivery_time(article_body, article_key_phrases)
    #We firstly test on the article_key_phrases => Score maximized
    raw_target = article_key_phrases.join(" ").match(/#REGEX/)

    if raw_target
      @delivery_delivery_score  = 1.to_f
      @delivery_delivery_presence = true
    else
      #We give it a second try on the whole body of the article => Score minimized
      raw_target = article_body.match(/#REGEX/)

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
    raw_target = article_key_phrases.join(" ").match(/#REGEX/)

    if raw_target
      @price_mention_score  = 1.to_f
      @price_mention_presence = true
    else
      #We give it a second try on the whole body of the article => Score minimized
      raw_target = article_body.match(/#REGEX/)

      if raw_target
      @price_mention_score = 0.66.to_f
      @price_mention_presence = true
      end
    end
  end

  def cgvu_price_euro_currency(article_body, article_key_phrases)
    #We firstly test on the article_key_phrases => Score maximized
    raw_target = article_key_phrases.join(" ").match(/#REGEX/)

    if raw_target
      @price_euro_currency_score  = 1.to_f
      @price_euro_currency_presence = true
    else
      #We give it a second try on the whole body of the article => Score minimized
      raw_target = article_body.match(/#REGEX/)

      if raw_target
      @price_euro_currency_score = 0.66.to_f
      @price_euro_currency_presence = true
      end
    end
  end

  def cgvu_price_ttc(article_body, article_key_phrases)
    #We firstly test on the article_key_phrases => Score maximized
    raw_target = article_key_phrases.join(" ").match(/#REGEX/)

    if raw_target
      @price_ttc_score  = 1.to_f
      @price_ttc_presence = true
    else
      #We give it a second try on the whole body of the article => Score minimized
      raw_target = article_body.match(/#REGEX/)

      if raw_target
      @price_ttc_score = 0.66.to_f
      @price_ttc_presence = true
      end
    end
  end

###############################################################
#PAYMENT

  def cgvu_payment_mention(article_body, article_key_phrases)
    #We firstly test on the article_key_phrases => Score maximized
    raw_target = article_key_phrases.join(" ").match(/#REGEX/)

    if raw_target
      @payment_mention_score  = 1.to_f
      @payment_mention_presence = true
    else
      #We give it a second try on the whole body of the article => Score minimized
      raw_target = article_body.match(/#REGEX/)

      if raw_target
      @payment_mention_score = 0.66.to_f
      @payment_mention_presence = true
      end
    end
  end

###############################################################
#CONTRACT CONCLUSION

  def cgvu_contract_conclusion_modality(article_body, article_key_phrases)
    #We firstly test on the article_key_phrases => Score maximized
    raw_target = article_key_phrases.join(" ").match(/#REGEX/)

    if raw_target
      @contract_conclusion_modality_score  = 1.to_f
      @contract_conclusion_modality_presence = true
    else
      #We give it a second try on the whole body of the article => Score minimized
      raw_target = article_body.match(/#REGEX/)

      if raw_target
      @contract_conclusion_modality_score = 0.66.to_f
      @contract_conclusion_modality_presence = true
      end
    end
  end

  def cgvu_contract_conclusion_offer_durability(article_body, article_key_phrases)
    #We firstly test on the article_key_phrases => Score maximized
    raw_target = article_key_phrases.join(" ").match(/#REGEX/)

    if raw_target
      @contract_conclusion_offer_durability_score  = 1.to_f
      @contract_conclusion_offer_durability_presence = true
    else
      #We give it a second try on the whole body of the article => Score minimized
      raw_target = article_body.match(/#REGEX/)

      if raw_target
      @contract_conclusion_offer_durability_score = 0.66.to_f
      @contract_conclusion_offer_durability_presence = true
      end
    end
  end

  def cgvu_contract_conclusion_human_error(article_body, article_key_phrases)
    #We firstly test on the article_key_phrases => Score maximized
    raw_target = article_key_phrases.join(" ").match(/#REGEX/)

    if raw_target
      @contract_conclusion_human_error_score  = 1.to_f
      @contract_conclusion_human_error_presence = true
    else
      #We give it a second try on the whole body of the article => Score minimized
      raw_target = article_body.match(/#REGEX/)

      if raw_target
      @contract_conclusion_human_error_score = 0.66.to_f
      @contract_conclusion_human_error_presence = true
      end
    end
  end

  def cgvu_contract_conclusion_agreement(article_body, article_key_phrases)
    #We firstly test on the article_key_phrases => Score maximized
    raw_target = article_key_phrases.join(" ").match(/#REGEX/)

    if raw_target
      @contract_conclusion_agreement_score  = 1.to_f
      @contract_conclusion_agreement_presence = true
    else
      #We give it a second try on the whole body of the article => Score minimized
      raw_target = article_body.match(/#REGEX/)

      if raw_target
      @contract_conclusion_agreement_score = 0.66.to_f
      @contract_conclusion_agreement_presence = true
      end
    end
  end

###############################################################
#RETRACTATION

  def cgvu_retractation_right(article_body, article_key_phrases)
    #We firstly test on the article_key_phrases => Score maximized
    raw_target = article_key_phrases.join(" ").match(/#REGEX/)

    if raw_target
      @retractation_right_score  = 1.to_f
      @retractation_right_presence = true
    else
      #We give it a second try on the whole body of the article => Score minimized
      raw_target = article_body.match(/#REGEX/)

      if raw_target
      @retractation_right_score = 0.66.to_f
      @retractation_right_presence = true
      end
    end
  end

###############################################################
#guarantee AND SAV

  def cgvu_guaranteeandsav_guarantee(article_body, article_key_phrases)
    #We firstly test on the article_key_phrases => Score maximized
    raw_target = article_key_phrases.join(" ").match(/#REGEX/)

    if raw_target
      @guaranteeandsav_guarantee_score  = 1.to_f
      @guaranteeandsav_guarantee_presence = true
    else
      #We give it a second try on the whole body of the article => Score minimized
      raw_target = article_body.match(/#REGEX/)

      if raw_target
      @guaranteeandsav_guarantee_score = 0.66.to_f
      @guaranteeandsav_guarantee_presence = true
      end
    end
  end

  def cgvu_guaranteeandsav_guarantee(article_body, article_key_phrases)
    #We firstly test on the article_key_phrases => Score maximized
    raw_target = article_key_phrases.join(" ").match(/#REGEX/)

    if raw_target
      @guaranteeandsav_guarantee_score  = 1.to_f
      @guaranteeandsav_guarantee_presence = true
    else
      #We give it a second try on the whole body of the article => Score minimized
      raw_target = article_body.match(/#REGEX/)

      if raw_target
      @guaranteeandsav_guarantee_score = 0.66.to_f
      @guaranteeandsav_guarantee_presence = true
      end
    end
  end
end











