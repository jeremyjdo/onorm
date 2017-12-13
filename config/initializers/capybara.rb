# require 'capybara/poltergeist'
# Capybara.register_driver :poltergeist do |app|
#   Capybara::Poltergeist::Driver.new(app,
#     phantomjs: Phantomjs.path,
#     js_errors: false,
#     autoLoadImages: false,
#     ignoreSslErrors: true
#     # url_blacklist: ['*/analytics_tool.js'] # can use * and ? wildcards in these
#   )
# end

# Capybara.default_driver = :poltergeist
# To debug with a real browser, if needed
# Capybara.register_driver :selenium do |app|
#   Capybara::Selenium::Driver.new(app, browser: :chrome)
# end

# Capybara.javascript_driver = :chrome

# Capybara.configure do |config|
#   config.default_max_wait_time = 10 # seconds
#   config.default_driver        = :selenium
# end
