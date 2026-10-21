# Marketline

A one-page Ruby stock explorer with searchable companies and interactive market charts.

Search by company name or ticker, choose a stock, and explore its price history with 1D, 5D, 1W, 1M, and 1Y controls. Switch between area and candlestick charts, zoom, draw, and add indicators through the chart toolbar. The layout adapts to mobile screens.

## How it works

- Sinatra validates stock, date-range, and style selections and renders ERB views. Selections are carried in the URL, so links can be bookmarked and shared. The chart's additional toolbar settings are local to the embedded chart.
- [Tom Select](https://tom-select.js.org/) provides keyboard-accessible autocomplete over 48 selected US-listed stocks in `data/stocks.json`. Search is local; it does not send queries to a market-data API. This is a curated catalog, not an exhaustive symbol directory.
- The [TradingView Advanced Chart widget](https://www.tradingview.com/widget-docs/widgets/charts/advanced-chart/) supplies actual market data, rendering, indicators, drawing tools, and zoom. No API key, database, account, or custom data feed is needed.
- Market data can be delayed and depends on TradingView's availability and exchange entitlements. The chart identifies its feed and time. The application does not manufacture prices or claim that every quote is real time.
- A native stock selector and ordinary links remain available without JavaScript. The interactive chart and autocomplete require JavaScript. Slow or failed chart loading displays a recovery message and a direct TradingView link remains available.
- Stock input is allowlisted on the server. Invalid selections return HTTP 400 with a recovery link; unknown pages return HTTP 404.

Ruby owns selection and configuration logic. The small browser script only initializes the two third-party controls and handles their loading state. Tom Select 2.6.2 is served locally to avoid a runtime CDN dependency; its license and provenance are under `public/vendor/`. The remotely hosted TradingView widget is maintained by its provider and cannot be version-pinned by this application.

## Setup

Install [mise](https://mise.jdx.dev/), then run these commands from this repository:

```sh
mise install
mise run setup
mise run dev
```

Open <http://localhost:9292>. `GET /health` returns `{"status":"ok"}` for deployment health checks.

Ruby is pinned in `mise.toml` and `Gemfile`. Tasks explicitly select mise's Ruby and use `bin/run.rb` to put that Ruby's directory first on `PATH`. This also keeps Bundler and Ruby subprocesses on the correct interpreter when a shell puts system Ruby first.

## Checks

```sh
mise run check
mise run test
mise run lint
mise run format-check
mise run format
```

`check` runs tests, lint, and formatting checks without changing source files. `format` applies safe formatting fixes. Test coverage is written to `coverage/index.html`. CI runs the same mise tasks on pushes and pull requests. Ruby tests cover the stock catalog, defaults, each range and style, URL state, invalid and structured input, rendered controls, escaping, error pages, health checks, and static assets.

## Configuration and deployment

`PORT` selects the listening port, defaulting to `9292`. `MAX_THREADS` selects Puma's thread count, defaulting to `3`. Set `RACK_ENV=production` when deploying.
