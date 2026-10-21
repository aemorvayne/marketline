require 'json'
require 'sinatra/base'

module Marketline
  class App < Sinatra::Base
    set :root, __dir__
    set :show_exceptions, false
    get '/health' do
      content_type :json
      JSON.generate(status: 'ok')
    end
  end
end
