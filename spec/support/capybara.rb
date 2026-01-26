require 'capybara/rspec'
require 'selenium-webdriver'

Capybara.register_driver :selenium_firefox_headless do |app|
  options = Selenium::WebDriver::Firefox::Options.new
  options.args << '--headless'
  # Recommended for CI (disable gpu, no-sandbox not usually needed for Firefox, but keep stable flags minimal)
  Capybara::Selenium::Driver.new(app, browser: :firefox, options: options)
end

Capybara.javascript_driver = :selenium_firefox_headless
Capybara.default_max_wait_time = 5
