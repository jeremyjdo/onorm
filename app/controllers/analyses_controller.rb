require 'net/https'
require 'uri'
require 'json'

class AnalysesController < ApplicationController
  def index
  end

  def show
  end

  def new
  end

  def create
  end

  def nlp
    uri = 'https://westeurope.api.cognitive.microsoft.com/'
    path = '/text/analytics/v2.0/keyPhrases'
    uri = URI(uri + path)
    documents = { 'documents': [
    { 'id' => '1', 'language' => 'fr', 'text' => 'En cas de commande vers un pays autre que la France métropolitaine vous êtes limportateur du ou des produits concernés. Pour tous les produits expédiés hors Union européenne et DOM-TOM, le prix sera calculé hors taxes automatiquement sur la facture. Des droits de douane ou autres taxes locales ou droits dimportation ou taxes détat sont susceptibles dêtre exigibles. Ces droits et sommes ne relèvent pas du ressort de Fnac Direct. Ils seront à votre charge et relèvent de votre entière responsabilité, tant en termes de déclarations que de paiements aux autorités et/organismes compétents de votre pays. Nous vous conseillons de vous renseigner sur ces aspects auprès de vos autorités locales.' },
    ]}

    puts 'Please wait a moment for the results to appear.'

    request = Net::HTTP::Post.new(uri)
    request['Content-Type'] = "application/json"
    request['Ocp-Apim-Subscription-Key'] = "780d7659e35c47cd9959d6a2ce61d961"
    request.body = documents.to_json

    response = Net::HTTP.start(uri.host, uri.port, :use_ssl => uri.scheme == 'https') do |http|
        http.request (request)
    end

    puts JSON::pretty_generate (JSON (response.body))
  end

  private

end
