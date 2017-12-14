require 'net/https'
require 'uri'
require 'json'

class CognitiveService

  def text_analysis(text)
    uri = 'https://westeurope.api.cognitive.microsoft.com/'
    path = '/text/analytics/v2.0/keyPhrases'
    uri = URI(uri + path)

    split_text = text.chars.each_slice(5000).map(&:join)
    nb_split_part = split_text.size

    case nb_split_part
    when 1
    documents = { 'documents': [
    { 'id' => '1', 'language' => 'fr', 'text' => split_text[0] },
    ]}
    when 2
    documents = { 'documents': [
    { 'id' => '1', 'language' => 'fr', 'text' => split_text[0] },
    { 'id' => '2', 'language' => 'fr', 'text' => split_text[1] },
    ]}
    when 3
    documents = { 'documents': [
    { 'id' => '1', 'language' => 'fr', 'text' => split_text[0] },
    { 'id' => '2', 'language' => 'fr', 'text' => split_text[1] },
    { 'id' => '3', 'language' => 'fr', 'text' => split_text[2] },
    ]}
    when 4
    documents = { 'documents': [
    { 'id' => '1', 'language' => 'fr', 'text' => split_text[0] },
    { 'id' => '2', 'language' => 'fr', 'text' => split_text[1] },
    { 'id' => '3', 'language' => 'fr', 'text' => split_text[2] },
    { 'id' => '4', 'language' => 'fr', 'text' => split_text[3] },
    ]}
    else
    documents = { 'documents': [
    { 'id' => '1', 'language' => 'fr', 'text' => text },
    ]}
    end

    puts 'Please wait a moment for the results to appear.'

    request = Net::HTTP::Post.new(uri)
    request['Content-Type'] = "application/json"
    request['Ocp-Apim-Subscription-Key'] = ENV["COGNITIVE_TEXT_ANALYSIS_KEY"]
    request.body = documents.to_json

    response = Net::HTTP.start(uri.host, uri.port, :use_ssl => uri.scheme == 'https') do |http|
      http.request (request)
    end

    json = JSON::pretty_generate (JSON (response.body))
    result = JSON.parse(json)

    p ""
    p ""
    p ""
    p "<------------------>"
    p ""
    p ""
    p ""
    p ""
    p ""
    p ""
    p ""
    p result
    p result["documents"]
    p result["documents"][0]
    p ""
    p ""
    p ""
    p "<------------------>"
    p ""
    p ""
    p ""
    p ""
    p ""
    p ""
    p ""
    article_key_phrases = []
    case nb_split_part
    when 1
    split_0 = result["documents"][0]["keyPhrases"]
    article_key_phrases << split_0 if split_0
    article_key_phrases = article_key_phrases.flatten

    when 2
    article_key_phrases = []
    split_1 = result["documents"][0]["keyPhrases"]
    article_key_phrases << split_1 if split_1
    split_2 = result["documents"][1]["keyPhrases"]
    article_key_phrases << split_2 if split_2
    article_key_phrases = article_key_phrases.flatten

    when 3
    article_key_phrases = []
    split_1 = result["documents"][0]["keyPhrases"]
    article_key_phrases << split_1 if split_1
    split_2 = result["documents"][1]["keyPhrases"]
    article_key_phrases << split_2 if split_2
    split_3 = result["documents"][2]["keyPhrases"]
    article_key_phrases << split_3 if split_3
    article_key_phrases = article_key_phrases.flatten

    when 4
    article_key_phrases = []
    split_1 = result["documents"][0]["keyPhrases"]
    article_key_phrases << split_1 if split_1
    split_2 = result["documents"][1]["keyPhrases"]
    article_key_phrases << split_2 if split_2
    split_3 = result["documents"][2]["keyPhrases"]
    article_key_phrases << split_3 if split_3
    split_4 = result["documents"][3]["keyPhrases"]
    article_key_phrases << split_4 if split_4
    article_key_phrases = article_key_phrases.flatten

    else
      if result["documents"] != []
    article_key_phrases = result["documents"][0]["keyPhrases"]
      else
        article_key_phrases = [""]
      end
    end
    return article_key_phrases
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

    json = JSON::pretty_generate(JSON(response.body))
    p JSON.parse(json)
  end
end
