require_relative 'time_formatter'

class App
  def call(env)
    request = Rack::Request.new(env)
    status, body = process_request(request)
    [status, headers, [body]]
  end

  private

  def process_request(request)
    return [404, "Page not found"] unless request.path == '/time'
    return [400, "Format not found in query string"] unless request.params['format']

    time_formatter = TimeFormatter.new(request.params['format'])

    if time_formatter.result
      [200, time_formatter.result]
    else
      [400, "Unknown time format [#{time_formatter.unsupported_formats.join(',')}]"]
    end
  end

  def headers
    { "Content-Type" => "text/plain" }
  end
end
