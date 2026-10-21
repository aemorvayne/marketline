require 'json'
require 'sinatra/base'
require_relative 'lib/marketline/chart'

module Marketline
  class App < Sinatra::Base
    set :root, __dir__
    set :show_exceptions, false
    helpers do
      def escape(value)
        Rack::Utils.escape_html(value)
      end
    end
    before do
      headers 'X-Content-Type-Options' => 'nosniff', 'Referrer-Policy' => 'strict-origin-when-cross-origin'
    end
    get '/' do
      @selection = Selection.new(params)
      @chart = Chart.new(@selection)
      erb :index
    end
    get '/health' do
      content_type :json
      JSON.generate(status: 'ok')
    end
    error Selection::Invalid do
      status Rack::Utils::SYMBOL_TO_STATUS_CODE.fetch(:bad_request)
      @message = env.fetch('sinatra.error').message
      erb :error
    end
    not_found do
      @message = 'This page could not be found. Return to the explorer to choose a stock.'
      erb :error
    end
  end
end
