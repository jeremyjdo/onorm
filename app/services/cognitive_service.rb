require 'net/https'
require 'uri'
require 'json'

class CognitiveService

  def text_analysis(text)
    uri = 'https://westeurope.api.cognitive.microsoft.com/'
    path = '/text/analytics/v2.0/keyPhrases'
    uri = URI(uri + path)
    documents = { 'documents': [
    { 'id' => '1', 'language' => 'fr', 'text' => text },
    ]}

    puts 'Please wait a moment for the results to appear.'

    request = Net::HTTP::Post.new(uri)
    request['Content-Type'] = "application/json"
    request['Ocp-Apim-Subscription-Key'] = ENV["COGNITIVE_TEXT_ANALYSIS_KEY"]
    request.body = documents.to_json

    response = Net::HTTP.start(uri.host, uri.port, :use_ssl => uri.scheme == 'https') do |http|
      http.request (request)
    end

    puts JSON::pretty_generate (JSON (response.body))
  end

  def luis(text)
    host = 'https://westeurope.api.cognitive.microsoft.com/'
    appId = ENV["COGNITIVE_LUIS_APPID_KEY"]
    subscriptionKey = ENV["COGNITIVE_LUIS_SUBSCRIPTION_KEY"]
    path = "/luis/v2.0/apps/"
    term = text
    if subscriptionKey.length != 32 then
      puts "Invalid LUIS API subscription key!"
      puts "Please paste yours into the source code."
      abort
    end
    qs = URI.encode_www_form(
      "q" => term,
      "timezoneOffset" => 0,
      "verbose" => false,
      "spellCheck" => false,
      "staging" => false
    )
    uri = URI(host + path + appId + "?" + qs)

    puts
    puts "LUIS query: " + term
    puts
    puts "Request URI: " + uri.to_s

    request = Net::HTTP::Get.new(uri)
    request["Ocp-Apim-Subscription-Key"] = subscriptionKey

    response = Net::HTTP.start(uri.host, uri.port, :use_ssl => uri.scheme == 'https') do |http|
      http.request(request)
    end

    puts "\nJSON Response:\n\n"
    puts JSON::pretty_generate(JSON(response.body))
  end

end
