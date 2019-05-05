require "cgi"

class App
  DATE_FORMATS = {
    "year" => "%Y",
    "month" => "%m",
    "day" => "%d"
  }.freeze

  TIME_FORMATS = {
    "hour" => "%H",
    "minute" => "%M",
    "second" => "%S"
  }.freeze

  FORMATS = DATE_FORMATS.keys + TIME_FORMATS.keys

  def call(env)
    @env = env
    @status = 200
    @body = ''
    check_path && check_params && check_format && prepare_time
    [status, headers, body]
  end

  private

  def check_path
    if @env['REQUEST_PATH'] == '/time'
      true
    else
      @status = 404
      @body = "Page not found"
      false
    end
  end

  def check_params
    params = CGI::parse(@env['QUERY_STRING'])
    @format = params['format'].first
    if @format
      true
    else
      @status = 400
      @body = "Format not found in query string"
      false
    end
  end

  def check_format
    @time_components = @format.split(',').map(&:strip)
    unknown_components = @time_components.select do |time_component|
      !FORMATS.include?(time_component)
    end

    if unknown_components.empty?
      true
    else
      @status = 400
      @body = "Unknown time format [#{unknown_components.join(',')}]"
      false
    end
  end

  def prepare_time
    date_str = DATE_FORMATS.map do |component, str|
      @time_components.include?(component) ? str : nil
    end.compact.join('-')

    time_str = TIME_FORMATS.map do |component, str|
      @time_components.include?(component) ? str : nil
    end.compact.join(':')

    @body = Time.now.strftime("#{date_str} #{time_str}")
  end

  def status
    @status
  end

  def headers
    { "Content-Type" => "text/plain" }
  end

  def body
    [@body]
  end
end
