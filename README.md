# Marketline

A small stock explorer built with Ruby and Sinatra. Find a company by name or ticker, switch between candles and an area chart, and explore anything from a single day to a year.

Choose from 48 US-listed stocks. [TradingView](https://www.tradingview.com/) provides the charts, drawing tools, and indicators; market data may be delayed. Your stock, range, and chart style stay in the URL, so you can share the view.

## Try it locally

With [mise](https://mise.jdx.dev/) installed:

```sh
mise install
mise run setup
mise run dev
```

Open <http://localhost:9292>. No API key, account, or database needed. The charts need an internet connection.

## Run the checks

```sh
mise run check
```

This runs Ruby and browser tests, lint, formatting, and privacy checks. Install Chrome or Chromium for the browser tests. Coverage is saved to `coverage/index.html`.

## Run with Docker

```sh
docker build -t marketline .
docker run --rm -p 9292:9292 marketline
```

On a container host, build the root `Dockerfile` and set the health check to `/health`. The app honors `PORT` (default `9292`); `MAX_THREADS` defaults to `3`. The image already uses production settings.

Also built with Ruby: [LCM Service](https://github.com/aemorvayne/lcm-service), a tiny HTTP calculator.
