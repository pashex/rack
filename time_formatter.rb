class TimeFormatter
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

  def initialize(format_param)
    @formats = format_param.to_s.split(',').map(&:strip)
    @strftime_format = "#{date_strftime} #{time_strftime}"
  end

  def unsupported_formats
    @unsupported_formats ||= @formats.select { |format| !FORMATS.include?(format) }
  end

  def result
    return if unsupported_formats.any?

    Time.now.strftime(@strftime_format)
  end

  private

  def date_strftime
    select_strftime_from(DATE_FORMATS, '-')
  end

  def time_strftime
    select_strftime_from(TIME_FORMATS, ':')
  end

  def select_strftime_from(hash, separator)
    hash.map do |format, strftime|
      @formats.include?(format) ? strftime : nil
    end.compact.join(separator)
  end
end
