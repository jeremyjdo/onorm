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
    init_capybara

    cookie_list
    cookie_banner?

    cookie_system_scorer
    cookie_system_generator

    quit_capybara
  end

  def cookie_list
    cookie_l = {}
    presence.split("; ").each do |c|
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

    raw_data = @session.first('div', text:'cookie')

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
      elsif @cookie_user_agreement && @analysis.cookie_system_url == ""
        @cookie_score = 0.5.to_f
      elsif !@cookie_user_agreement && @analysis.cookie_system_url != ""
        @cookie_score = 0.5.to_f
      elsif !@cookie_user_agreement
        @cookie_score = 0.to_f
      end
      @cookie_score = (@cookie_score * 20)
      @cookie_score.round(2)
    else
      @cookie_score = 1.to_f
      @cookie_score = (@cookie_score * 20)
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

    @analysis.calculate_score

    ActionCable.server.broadcast("cookie_system_for_analysis_#{@analysis.id}", {
      cookie_header_partial: ApplicationController.renderer.render(
        partial: "analyses/cookie_header",
        locals: { cookie_system: @cookie_system }
      ),
      cookie_panel_partial: ApplicationController.renderer.render(
        partial: "analyses/cookie_panel",
        locals: { analysis: @analysis },
      ),
      score_header_partial: ApplicationController.renderer.render(
      partial: "analyses/score_header",
      locals: { analysis: @analysis },
      )
    })
  end

  # test sur plusieurs sites
  # def cookie_test
  #   puts ""
  #   puts "TEST Blizzard : True"
  #   puts
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

  def presence

    # To get the desktop version for the scraped page, in order to get access
    # to the flat booking form

    cookies = @session.evaluate_script("document.cookie")

    return cookies
  end

  def init_capybara
    require 'capybara/poltergeist'
     Capybara.register_driver :poltergeist do |app|
      Capybara::Poltergeist::Driver.new(app,
        phantomjs: Phantomjs.path,
        js_errors: false,
        autoLoadImages: false,
        ignoreSslErrors: true
        # url_blacklist: ['*/analytics_tool.js'] # can use * and ? wildcards in these
      )
    end

    @session = Capybara::Session.new(:poltergeist)
    url = @analysis.website_url
    @session.visit(url)

    # Capybara.default_driver = :poltergeist

    # puts ""
    # puts ""
    # puts '<=====================>'
    # puts ""
    # puts ""
    # puts Capybara.methods - Object.methods
    # puts ""
    # puts ""
    # puts '<=====================>'
    # puts ""
    # puts ""
    # puts @session
    # puts @session.class
    # puts @session.methods - Object.methods
    # puts ""
    # puts ""
    # puts '<=====================>'
    # puts ""
    # puts ""

    # @session.driver.clear_memory_cache

  end

  def quit_capybara
    @session.reset_session!
    @session.driver.quit
    @session = nil
  end
end
