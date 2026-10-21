require_relative 'test_helper'

class AppTest < Minitest::Test
  include Rack::Test::Methods
  def app
    Marketline::App
  end

  def test_health_check
    get '/health'
    assert last_response.ok?
    assert_equal 'application/json', last_response.media_type
    assert_equal({ 'status' => 'ok' }, JSON.parse(last_response.body))
  end
end
