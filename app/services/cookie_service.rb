
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
