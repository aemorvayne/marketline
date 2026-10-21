require_relative 'test_helper'

class SelectionTest < Minitest::Test
  def test_defaults
    selection = Marketline::Selection.new
    assert_equal 'Apple', selection.stock.fetch('name')
    assert_equal 'NASDAQ:AAPL', selection.symbol
    assert_equal '1m', selection.range_key
    assert_equal 'area', selection.style_key
  end

  def test_every_catalog_stock_is_selectable
    Marketline::Catalog::STOCKS.each do |stock|
      selection = Marketline::Selection.new('symbol' => stock.fetch('symbol'))
      assert_equal stock, selection.stock
    end
  end

  def test_catalog_symbols_are_unique
    symbols = Marketline::Catalog::STOCKS.map { |stock| stock.fetch('symbol') }
    assert_equal symbols.uniq, symbols
  end

  def test_featured_stocks_belong_to_the_catalog
    Marketline::Catalog.featured.each do |stock|
      assert_includes Marketline::Catalog::STOCKS, stock
    end
  end

  def test_required_ranges
    { '1d' => '1D', '5d' => '5D', '1w' => '1W', '1m' => '1M', '1y' => '12M' }.each do |key, period|
      assert_equal period, Marketline::Selection.new('range' => key).range.period
    end
  end

  def test_chart_styles
    assert_equal '3', Marketline::Selection.new('style' => 'area').chart_style
    assert_equal '1', Marketline::Selection.new('style' => 'candles').chart_style
  end

  def test_unknown_empty_and_structured_symbols_are_rejected
    ['UNKNOWN', '', nil, [], {}, '<script>alert(1)</script>'].each do |symbol|
      assert_raises(Marketline::Selection::Invalid) { Marketline::Selection.new('symbol' => symbol) }
    end
  end

  def test_unknown_empty_and_structured_ranges_are_rejected
    ['2y', '', nil, [], {}].each do |range|
      assert_raises(Marketline::Selection::Invalid) { Marketline::Selection.new('range' => range) }
    end
  end

  def test_unknown_empty_and_structured_styles_are_rejected
    ['bars', '', nil, [], {}].each do |style|
      assert_raises(Marketline::Selection::Invalid) { Marketline::Selection.new('style' => style) }
    end
  end

  def test_links_preserve_selection_and_encode_symbols
    selection = Marketline::Selection.new('symbol' => 'NYSE:BRK.B', 'style' => 'candles')
    assert_equal '/?symbol=NYSE%3ABRK.B&range=1y&style=candles#chart', selection.path(range: '1y')
    assert_equal '/?symbol=NASDAQ%3AMSFT&range=1m&style=candles#chart', selection.path(symbol: 'NASDAQ:MSFT')
  end

  def test_provider_link
    selection = Marketline::Selection.new('symbol' => 'NYSE:BRK.B')
    assert_equal 'https://www.tradingview.com/symbols/NYSE-BRK.B/', selection.provider_url
  end
end
