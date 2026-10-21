# Marketline

A Ruby stock-chart application with interactive market charts.

## Setup

Install [mise](https://mise.jdx.dev/), then run these commands from this repository:

```sh
mise install
mise run setup
mise run dev
```

Open <http://localhost:9292>. `GET /health` returns a JSON health check. The stock-chart page is under development.

Ruby is pinned in `mise.toml` and `Gemfile`. Tasks explicitly select mise's Ruby and use `bin/run.rb` to put that Ruby's directory first on `PATH`. This also keeps Bundler and Ruby subprocesses on the correct interpreter when a shell puts system Ruby first.

## Checks

```sh
mise run check
mise run test
mise run lint
mise run format-check
mise run format
```

`check` runs tests, lint, and formatting checks without changing source files. `format` applies safe formatting fixes. Test coverage is written to `coverage/index.html`. CI runs the same mise tasks on pushes and pull requests.

## Configuration and deployment

`PORT` selects the listening port, defaulting to `9292`. `MAX_THREADS` selects Puma's thread count, defaulting to `3`. Set `RACK_ENV=production` when deploying.
