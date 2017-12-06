class CookieService
  def initialize
    reponse = RestClient.get 'https://www.doctrine.fr'
    cookies = reponse.cookies
  end
end
