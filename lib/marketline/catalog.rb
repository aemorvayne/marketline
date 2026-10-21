require 'json'

module Marketline
  module Catalog
    STOCKS = JSON.parse(File.read(File.expand_path('../../data/stocks.json', __dir__)), freeze: true)
    BY_SYMBOL = STOCKS.to_h { |stock| [stock.fetch('symbol'), stock] }.freeze
    DEFAULT_SYMBOL = 'NASDAQ:AAPL'.freeze
    FEATURED_SYMBOLS = %w[NASDAQ:AAPL NASDAQ:MSFT NASDAQ:NVDA NASDAQ:AMZN NASDAQ:TSLA].freeze
    def self.find(symbol)
      BY_SYMBOL.fetch(symbol)
    end

    def self.featured
      FEATURED_SYMBOLS.map { |symbol| find(symbol) }
    end
  end
end
