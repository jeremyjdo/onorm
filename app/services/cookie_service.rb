
class CookieService

  private

  attr_reader :url, :browser

  public

  def presence(url)
    init_capybara

    @browser = Capybara.current_session

    # To get the desktop version for the scraped page, in order to get access
    # to the flat booking form
    @browser.driver.resize(3072, 2304)

    @browser.visit(url)

    cookies = @browser.evaluate_script("document.cookie")

    return cookies
  end

  def cookie_list(url)
    cookie_l = {}
    presence(url).split("; ").each do |c|
      a = c.split("=")
      cookie_l[a[0].to_sym] = a[1]
    end
    # returns a hash of cookies
    return cookie_l
  end

  def cookie_banner?(url)
    # has_banner = false
    init_capybara

    @browser = Capybara.current_session

    # To get the desktop version for the scraped page, in order to get access
    # to the flat booking form
    @browser.driver.resize(3072, 2304)

    @browser.visit(url)

    raw_data = browser.first('div', text:'cookie')

    # p raw_data
    return !raw_data.nil?

    # if !raw_data.nil?
    #   # prints the content of the banner text, with a bit more if the div is large
    #   # p raw_data.text
    #   has_banner = true
    # end

    # return has_banner
  end

  # test sur plusieurs sites
  def cookie_test
    puts ""
    puts "TEST Blizzard : True"
    puts cookie_banner?('https://www.blizzard.com/fr-fr/')

    puts ""
    puts "TEST Parlement Euro : True"
    puts cookie_banner?('http://www.europarl.europa.eu/portal/fr')

    puts ""
    puts "Test Fnac : True"
    puts cookie_banner?('https://www.fnac.com/')

    puts ""
    puts "TNW : True"
    puts cookie_banner?('https://thenextweb.com/')

    puts ""
    puts "Doctrine : False"
    puts cookie_banner?('https://doctrine.fr/')
  end


  private

  def init_capybara
    require 'capybara/poltergeist'
    Capybara.register_driver :poltergeist do |app|
      Capybara::Poltergeist::Driver.new(app, phantomjs: Phantomjs.path, js_errors: false)
    end

    Capybara.default_driver = :poltergeist

    # To debug with a real browser, if needed
    # Capybara.register_driver :selenium do |app|
    #   Capybara::Selenium::Driver.new(app, browser: :chrome)
    # end

    # Capybara.javascript_driver = :chrome

    # Capybara.configure do |config|
    #   config.default_max_wait_time = 10 # seconds
    #   config.default_driver        = :selenium
    # end
  end
end
