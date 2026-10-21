require_relative 'test_helper'

class AppTest < Minitest::Test
  include Rack::Test::Methods
  def app
    Marketline::App
  end

  def test_health_check
    get '/health'
    assert last_response.ok?
    assert_equal 'application/json', last_response.media_type
    assert_equal({ 'status' => 'ok' }, JSON.parse(last_response.body))
  end

  def test_home_page_shows_default_stock
    get '/'
    assert last_response.ok?
    assert_equal 'Apple', document.at_css('#stock-name').text
    assert_equal 'NASDAQ:AAPL', document.at_css('#symbol option[selected]')['value']
  end

  def test_home_page_offers_required_ranges_and_styles
    get '/'
    assert_equal %w[1D 5D 1W 1M 1Y], document.css('.range-controls a').map(&:text)
    assert_equal %w[Area Candles], document.css('.style-controls a').map(&:text)
  end

  def test_page_renders_the_selected_chart_options
    get '/', symbol: 'NYSE:KO', range: '5d', style: 'candles'
    assert last_response.ok?
    expected = { 'symbol' => 'NYSE:KO', 'range' => '5D', 'style' => '1' }
    assert_equal expected, chart_options.slice(*expected.keys)
  end

  def test_page_identifies_the_selected_stock_and_controls
    get '/', symbol: 'NYSE:KO', range: '5d', style: 'candles'
    assert_equal 'Coca-Cola', document.at_css('#stock-name').text
    assert_equal '5D', document.at_css('.range-controls [aria-current]').text
    assert_equal 'Candles', document.at_css('.style-controls [aria-current]').text
  end

  def test_invalid_symbols_produce_a_recoverable_error
    get '/', symbol: 'missing'
    assert last_response.bad_request?
    assert_includes document.text, 'Choose a listed stock'
    assert document.at_css('a.primary-link[href="/"]')
    assert_empty document.css('#chart-options')
  end

  def test_invalid_ranges_and_styles_are_rejected
    [{ range: 'invalid' }, { style: 'invalid' }, { symbol: '' }, { range: ['1m'] }].each do |parameters|
      get '/', parameters
      assert last_response.bad_request?, parameters.inspect
    end
  end

  def test_nested_parameters_are_rejected
    get '/?symbol[]=NASDAQ:AAPL'
    assert last_response.bad_request?
    get '/?range[period]=1m'
    assert last_response.bad_request?
  end

  def test_malicious_query_is_not_reflected
    payload = '<script>alert("unsafe")</script>'
    get '/', symbol: payload
    assert last_response.bad_request?
    refute_includes last_response.body, payload
  end

  def test_company_names_are_escaped_and_remain_readable
    get '/', symbol: 'NYSE:T'
    assert_equal 'AT&T', document.at_css('#stock-name').text
    assert_includes last_response.body, 'AT&amp;T'
  end

  def test_unknown_pages_offer_a_way_back
    get '/missing'
    assert last_response.not_found?
    assert_includes document.text, 'This page could not be found'
    assert document.at_css('a.primary-link[href="/"]')
  end

  def test_provider_attribution_and_data_delay_are_visible
    get '/'
    assert_includes document.text, 'Market data may be delayed'
    assert_match(%r{https://www.tradingview.com/symbols/NASDAQ-AAPL/}, document.at_css('.source-link')['href'])
    assert_includes document.at_css('.tradingview-widget-copyright').text, 'by TradingView'
    assert_includes document.at_css('noscript').text, 'JavaScript is needed'
  end

  def test_static_assets_are_served
    %w[/app.css /app.js /favicon.svg /vendor/tom-select.js /vendor/tom-select.css].each do |path|
      get path
      assert last_response.ok?, path
      refute_empty last_response.body
    end
  end

  def test_security_headers
    get '/'
    assert_equal 'nosniff', last_response.headers.fetch('x-content-type-options')
    assert_equal 'strict-origin-when-cross-origin', last_response.headers.fetch('referrer-policy')
  end

  def document
    Nokogiri::HTML(last_response.body)
  end

  def chart_options
    JSON.parse(document.at_css('#chart-options').text)
  end
end
