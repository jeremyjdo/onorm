require 'open-uri'
require 'nokogiri'

class CGVUService

attr_accessor :raw_articles

  def initialize(analysis, brain)
    @analysis = analysis

    @cgvu_score = 0.to_f

    @raw_articles = []

    @brain = brain
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

  end

  private

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

  def articles_analyze
    #@raw_articles.each do |raw_article|
      selected_key_concepts_pools = []
      # article_identification(raw_article)
    #end
      article_identification(@raw_articles[0], selected_key_concepts_pools)
      article_evaluation(@raw_articles[0], selected_key_concepts_pools)
  end

  def article_identification(raw_article, selected_key_concepts_pools)
    result = @brain.luis(raw_article[0])
    entities = result["entities"]
    entities.each do |entity|

      case entity
      #when "TRentitynameforonekeythematic"
        #@cgvu_TRthematic_article_presence = true
        #selected_key_concepts_pools << @TRthematic_key_concepts_pool
      #when "TRentitynameforonekeythematic"
        #@cgvu_TRthematic_article_presence = true
        #selected_key_concepts_pools << @TRthematic_key_concepts_pool
      #when "TRentitynameforonekeythematic"
        #@cgvu_TRthematic_article_presence = true
        #selected_key_concepts_pools << @TRthematic_key_concepts_pool
      end


    end
  end

  def article_evaluation(raw_article, selected_key_concepts_pools)

  end
end


#     doc.at('page').search('image, text, video').each do |node|
#   ...
# end

#     raw_target = html_doc.search("body").text.match(/\b(SA|SAS|SARL|SASU|EI|EIRL|EURL|EARL|GAEC|GEIE|GIE|SASU|SC|SCA|SCI|SCIC|SCM|SCOP|SCP|SCS|SEL|SELAFA|SELARL|SELAS|SELCA|SEM|SEML|SEP|SICA|SNC)\b/)
#     if raw_target
#       @identification_legal_form_text  = raw_target.to_s
#       @identification_legal_form_presence = true

#       @identification_company_name_presence = true

# doc.css(".headline").each do |item|
#   puts item.text
#   puts item.next_element.text
# end

