require_relative 'selection'

module Marketline
  class Chart
    PROVIDER_SCRIPT = 'https://s3.tradingview.com/external-embedding/embed-widget-advanced-chart.js'.freeze
    DEFAULT_OPTIONS = {
      autosize: true,
      timezone: 'exchange',
      theme: 'light',
      locale: 'en',
      backgroundColor: '#ffffff',
      gridColor: 'rgba(31, 52, 42, 0.05)',
      allow_symbol_change: false,
      hide_side_toolbar: false,
      withdateranges: true,
      save_image: true,
      calendar: false,
      support_host: 'https://www.tradingview.com'
    }.freeze
    def initialize(selection)
      @selection = selection
    end

    def options
      DEFAULT_OPTIONS.merge(symbol: @selection.symbol, range: @selection.range.period,
                            interval: @selection.range.interval, style: @selection.chart_style)
    end
  end
end
