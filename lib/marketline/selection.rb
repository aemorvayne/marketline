require 'uri'
require_relative 'catalog'

module Marketline
  class Selection
    class Invalid < StandardError; end
    Range = Data.define(:label, :period, :interval)
    RANGES = {
      '1d' => Range.new('1D', '1D', '1'),
      '5d' => Range.new('5D', '5D', '5'),
      '1w' => Range.new('1W', '1W', '15'),
      '1m' => Range.new('1M', '1M', '60'),
      '1y' => Range.new('1Y', '12M', 'D')
    }.freeze
    STYLES = { 'area' => '3', 'candles' => '1' }.freeze
    DEFAULT_RANGE = '1m'.freeze
    DEFAULT_STYLE = 'area'.freeze
    attr_reader :stock, :range_key, :style_key
    def initialize(parameters = {})
      @stock = Catalog.find(parameters.fetch('symbol', Catalog::DEFAULT_SYMBOL))
      @range_key = parameters.fetch('range', DEFAULT_RANGE)
      @style_key = parameters.fetch('style', DEFAULT_STYLE)
      RANGES.fetch(range_key)
      STYLES.fetch(style_key)
    rescue KeyError
      raise Invalid, 'Choose a listed stock, a supported date range, and either Area or Candles.'
    end

    def symbol
      stock.fetch('symbol')
    end

    def range
      RANGES.fetch(range_key)
    end

    def chart_style
      STYLES.fetch(style_key)
    end

    def path(**changes)
      parameters = { symbol: symbol, range: range_key, style: style_key }.merge(changes)
      "/?#{URI.encode_www_form(parameters)}#chart"
    end

    def provider_url
      "https://www.tradingview.com/symbols/#{symbol.tr(':', '-')}/"
    end
  end
end
