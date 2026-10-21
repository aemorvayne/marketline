class ChartProviderStub
  SCRIPT_PATH = '/test-chart-provider.js'.freeze
  SCRIPT = File.read(File.expand_path('../fixtures/chart_provider.js', __dir__)).freeze
  attr_accessor :unavailable, :empty
  def initialize(app)
    @app = app
    @unavailable = false
    @empty = false
  end

  def call(environment)
    return script_response if environment.fetch('PATH_INFO') == SCRIPT_PATH
    status, headers, body = @app.call(environment)
    return [status, headers, body] unless headers.fetch('content-type', '').include?('text/html')
    html = replace_provider(body)
    [status, headers.merge('content-length' => html.bytesize.to_s), [html]]
  end

  def script_response
    status = Rack::Utils::SYMBOL_TO_STATUS_CODE.fetch(unavailable ? :service_unavailable : :ok)
    [status, { 'content-type' => 'application/javascript' }, [unavailable || empty ? '' : SCRIPT]]
  end

  def replace_provider(body)
    html = +''
    body.each { |part| html << part }
    html.gsub(Marketline::Chart::PROVIDER_SCRIPT, SCRIPT_PATH)
  ensure
    body.close if body.respond_to?(:close)
  end
end
