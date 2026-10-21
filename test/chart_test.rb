require_relative 'test_helper'

class ChartTest < Minitest::Test
  def test_chart_uses_the_selected_stock_range_and_style
    selection = Marketline::Selection.new('symbol' => 'NASDAQ:MSFT', 'range' => '1y', 'style' => 'candles')
    options = Marketline::Chart.new(selection).options
    assert_equal 'NASDAQ:MSFT', options.fetch(:symbol)
    assert_equal '12M', options.fetch(:range)
    assert_equal 'D', options.fetch(:interval)
    assert_equal '1', options.fetch(:style)
  end

  def test_chart_is_responsive_and_keeps_external_symbol_changes_disabled
    options = Marketline::Chart.new(Marketline::Selection.new).options
    assert options.fetch(:autosize)
    assert options.fetch(:withdateranges)
    refute options.fetch(:allow_symbol_change)
    refute options.fetch(:hide_side_toolbar)
  end

  def test_one_week_uses_the_provider_supported_day_range
    selection = Marketline::Selection.new('range' => '1w')
    assert_equal '7D', Marketline::Chart.new(selection).options.fetch(:range)
  end
end
