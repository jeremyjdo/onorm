class CookieService

  private

  attr_reader :url, :browser

  public

  def initialize(analysis)
    @analysis = analysis
    @cookies_list = {}
    @cookie_usage = false
    @cookie_user_agreement = false
    @cookie_score = 0.to_f
  end

  def call
    cookie_list
    cookie_banner?

    cookie_system_scorer
    cookie_system_generator
  end

  def cookie_list
    url = @analysis.website_url
    cookie_l = {}
    presence(url).split("; ").each do |c|
      a = c.split("=")
      cookie_l[a[0].to_sym] = a[1]
    end

    if cookie_l != {}
      @cookie_usage = true
      @cookies_list = cookie_l
    else
      @cookie_usage = false
    end
  end

  def cookie_banner?
    # has_banner = false
    url = @analysis.website_url
    init_capybara

    @browser = Capybara.current_session

    # To get the desktop version for the scraped page, in order to get access
    # to the flat booking form
    @browser.driver.resize(3072, 2304)

    @browser.visit(url)

    raw_data = browser.first('div', text:'cookie')

    # returns true if site has banner
    if !raw_data.nil?
      @cookie_user_agreement = true
    else
      @cookie_user_agreement = false
    end
  end

  def cookie_system_scorer
    if @cookie_usage
      if @cookie_user_agreement && @analysis.cookie_system_url != ""
        @cookie_score = 1.to_f
      elsif @cookie_user_agreement || @analysis.cookie_system_url != ""
        @cookie_score = 0.5.to_f
      end
      @cookie_score = (@cookie_score * 50)
      @cookie_score.round(2)
    end
  end

  def cookie_system_generator
    @cookie_system = CookieSystem.new

    @cookie_system.cookie_usage = @cookie_usage

    @cookie_system.cookie_user_agreement = @cookie_user_agreement

    @cookie_system.score = @cookie_score

    @cookie_system.analysis = @analysis

    @cookie_system.save!
  end

  # # test sur plusieurs sites
  # def cookie_test
  #   puts ""
  #   puts "TEST Blizzard : True"
  #   puts cookie_banner?('https://www.blizzard.com/fr-fr/')

  #   puts ""
  #   puts "TEST Parlement Euro : True"
  #   puts cookie_banner?('http://www.europarl.europa.eu/portal/fr')

  #   puts ""
  #   puts "Test Fnac : True"
  #   puts cookie_banner?('https://www.fnac.com/')

  #   puts ""
  #   puts "TNW : True"
  #   puts cookie_banner?('https://thenextweb.com/')

  #   puts ""
  #   puts "Doctrine : False"
  #   puts cookie_banner?('https://doctrine.fr/')
  # end


  private

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
