require_relative 'test_helper'
require 'capybara/minitest'
require 'selenium-webdriver'
require_relative 'support/chart_provider_stub'

Capybara.app = ChartProviderStub.new(Marketline::App)
Capybara.server = :puma, { Silent: true }
Capybara.enable_aria_label = true
Capybara.register_driver :headless_chrome do |app|
  options = Selenium::WebDriver::Chrome::Options.new
  options.add_argument('--headless=new')
  options.add_argument('--window-size=1440,1100')
  options.add_argument('--no-sandbox') if ENV['CI']
  options.add_option('goog:loggingPrefs', { browser: 'ALL' })
  Capybara::Selenium::Driver.new(app, browser: :chrome, options: options)
end

class BrowserTestCase < Minitest::Test
  include Capybara::DSL
  include Capybara::Minitest::Assertions
  WAIT_SECONDS = 5
  MOBILE_HEIGHT = 844
  DEVICE_SCALE = 1
  def setup
    Capybara.current_driver = :headless_chrome
    Capybara.default_max_wait_time = WAIT_SECONDS
    Capybara.app.unavailable = false
    Capybara.app.empty = false
    browser.execute_cdp('Emulation.clearDeviceMetricsOverride')
    browser.execute_cdp('Network.enable')
    browser.execute_cdp('Network.setBlockedURLs', urls: ['https://*'])
    browser.logs.get(:browser)
  end

  def teardown
    Capybara.reset_sessions!
    Capybara.use_default_driver
  end

  def browser
    page.driver.browser
  end

  def mobile_viewport(width)
    browser.execute_cdp('Emulation.setDeviceMetricsOverride', width: width, height: MOBILE_HEIGHT,
                                                              deviceScaleFactor: DEVICE_SCALE, mobile: true)
  end

  def search_for(query)
    find('.ts-control').click
    find('#symbol-ts-control').set(query)
  end

  def selected_options
    JSON.parse(find('#chart-options', visible: false).text(:all))
  end

  def assert_no_horizontal_overflow
    assert page.evaluate_script('document.documentElement.scrollWidth <= window.innerWidth')
  end

  def assert_no_browser_errors
    errors = browser.logs.get(:browser).select { |entry| entry.level == 'SEVERE' }
    assert_empty errors.map(&:message)
  end
end
