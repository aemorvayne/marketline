require_relative 'browser_helper'

class BrowserTest < BrowserTestCase
  MOBILE_WIDTHS = [320, 390, 768].freeze
  CHART_TIMEOUT_WAIT_SECONDS = 25
  def test_search_by_company_with_keyboard
    visit '/'
    search_for('Microsoft')
    assert_selector '.ts-dropdown .option', text: 'MSFT'
    find('#symbol-ts-control').send_keys(:arrow_down, :enter)
    assert_selector '#stock-name', text: 'Microsoft'
    assert_equal 'NASDAQ:MSFT', selected_options.fetch('symbol')
    assert_no_browser_errors
  end

  def test_search_by_ticker_and_no_results
    visit '/'
    search_for('not-a-listed-company')
    assert_selector '.ts-dropdown', text: 'No results found'
    search_for('NVDA')
    find('.ts-dropdown .option', text: 'NVIDIA').click
    assert_selector '#stock-name', text: 'NVIDIA'
    assert_no_browser_errors
  end

  def test_quick_picks_ranges_and_styles_preserve_each_other
    visit '/?range=1y&style=candles'
    within('.featured') { click_link 'AMZN' }
    assert_selector '#stock-name', text: 'Amazon'
    click_link '1D date range'
    assert_selector '.range-controls [aria-current]', text: '1D'
    assert_selector '.style-controls [aria-current]', text: 'Candles'
    assert_equal 'NASDAQ:AMZN', selected_options.fetch('symbol')
    assert_no_browser_errors
  end

  def test_chart_loading_sets_accessible_frame_title
    visit '/'
    assert_selector 'iframe[title="Interactive stock price chart by TradingView"]'
    assert_selector '#chart-status', text: 'Use the chart toolbar'
    assert_no_browser_errors
  end

  def test_provider_failure_offers_recovery
    Capybara.app.unavailable = true
    visit '/'
    assert_selector '#chart-status', text: 'The chart is taking longer to load'
    assert_selector '.source-link[href="https://www.tradingview.com/symbols/NASDAQ-AAPL/"]'
    within('.featured') { click_link 'MSFT' }
    assert_selector '#stock-name', text: 'Microsoft'
  end

  def test_mobile_layout_does_not_overflow
    MOBILE_WIDTHS.each do |width|
      mobile_viewport(width)
      visit '/'
      assert_selector '.ts-control'
      assert_no_horizontal_overflow
      assert_selector '.range-controls a', count: Marketline::Selection::RANGES.length
    end
  end

  def test_chart_timeout_offers_recovery
    Capybara.app.empty = true
    visit '/'
    assert_selector '#chart-status', text: 'Loading the interactive chart'
    assert_selector '#chart-status', text: 'The chart is taking longer', wait: CHART_TIMEOUT_WAIT_SECONDS
    assert_no_browser_errors
  end

  def test_native_selector_survives_autocomplete_script_failure
    browser.execute_cdp('Network.setBlockedURLs', urls: ['https://*', '*/vendor/tom-select.js'])
    visit '/'
    select 'MSFT · Microsoft · NASDAQ', from: 'Find a stock'
    click_button 'View chart'
    assert_selector '#stock-name', text: 'Microsoft'
    assert_selector 'iframe[title="Interactive stock price chart by TradingView"]'
  end

  def test_mobile_search_and_controls
    mobile_viewport(MOBILE_WIDTHS.first)
    visit '/'
    search_for('Tesla')
    find('.ts-dropdown .option', text: 'TSLA').click
    assert_selector '#stock-name', text: 'Tesla'
    click_link '1W date range'
    click_link 'Candles', exact: true
    assert_selector '.range-controls [aria-current]', text: '1W'
    assert_no_horizontal_overflow
    assert_no_browser_errors
  end

  def test_error_page_returns_to_the_explorer
    visit '/?symbol=missing'
    assert_selector 'h1', text: 'That view isn’t available'
    click_link 'Back to the stock explorer'
    assert_selector '#stock-name', text: 'Apple'
  end

  def test_native_form_works_without_javascript
    Capybara.using_driver(:rack_test) do
      visit '/'
      select 'MSFT · Microsoft · NASDAQ', from: 'Find a stock'
      click_button 'View chart'
      assert_selector '#stock-name', text: 'Microsoft'
      click_link '1Y date range'
      assert_selector '.range-controls [aria-current]', text: '1Y'
    end
  end
end
