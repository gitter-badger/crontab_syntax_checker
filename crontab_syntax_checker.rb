class CrontabLine
  @@entry_regex = /^([,0-9*]+)\s+([,0-9*]+)\s+([,0-9*]+)\s+([,0-9*]+)\s+([,0-9*]+)\s+(.*)$/
  def initialize
    @minute = []
    @hour = []
    @day = []
    @month = []
    @weekday = []
    @command = ""
  end
  def minute
    param_getter(:@minute)
  end
  def minute=(value)
    value = value.to_s unless value.instance_of?(String)
    check_minute(value)
    param_setter(:@minute, value)
  end
  def hour
    param_getter(:@hour)
  end
  def hour=(value)
    value = value.to_s unless value.instance_of?(String)
    check_hour(value)
    param_setter(:@hour, value)
  end
  def day
    param_getter(:@day)
  end
  def day=(value)
    value = value.to_s unless value.instance_of?(String)
    check_day(value)
    param_setter(:@day, value)
  end
  def month
    param_getter(:@month)
  end
  def month=(value)
    value = value.to_s unless value.instance_of?(String)
    check_month(value)
    param_setter(:@month, value)
  end
  def weekday
    param_getter(:@weekday)
  end
  def weekday=(value)
    value = value.to_s unless value.instance_of?(String)
    check_weekday(value)
    param_setter(:@weekday, value)
  end
  attr_reader :command
  def command=(value)
    value = "" if value.nil?
    value = value.to_s unless value.instance_of?(String)
    @command = value
  end
  def self.create_by_hash(crontab_hash)
    crontab = CrontabLine.new
    crontab_hash.each() do |key, value|
        crontab.public_send(key, value)
    end
    crontab
  end
  def self.create_by_entry(entry)
    md = @@entry_regex.match(entry) 
    if md
      crontab = CrontabLine.new
      crontab.minute = md[1]
      crontab.hour = md[2]
      crontab.day = md[3]
      crontab.month = md[4]
      crontab.weekday = md[5]
      crontab.command = md[7]
      crontab
    else
      raise error_message(entry, "Entry did match expected pattern")
    end
  end
  def to_s
    [@minute, @hour, @day, @month, @weekday, @command].join(" ") + "\n"
  end
  private
  def param_getter(param)
    if instance_variable_get(param).empty?
      "*"
    else
      instance_variable_get(param).join(",")
    end
  end
  def param_setter(param, value)
    if value.nil?
      value = '*'
    end
    if value =~ /\*/
      instance_variable_set(param, [])
    else
      instance_variable_set(param, value.split(",", -1))
    end
  end
  def check_minute(minute_entry)
    return if minute_entry.nil?
    
    minutes = minute_entry.split(",",-1)
    minutes.each do |minute|
      raise error_message(minute_entry, "minute cannot contain a trailing comma") if minute == ""
      
      minute_ranges = minute.split("-",-1)
      raise error_message(minute_entry,"minute cannot contain more than one '-'") if minute_ranges.size > 2
      raise error_message(minute_entry,"minute contains an invalid range") if minute_ranges.size == 2 && minute_ranges[0].to_i > minute_ranges[1].to_i
      
      minute_ranges.each do |minute_range|
        raise error_message(minute_entry,"minute in a range can only contain numbers") if minute_ranges.size == 2 && minute_range !~ /^[0-9]+$/
        
        minute_divisors = minute_range.split("/",-1)
        raise error_message(minute_entry,"minute cannot contain more than one '/'") if minute_divisors.size > 2
        raise error_message(minute_entry, "divisor must be a number greater than 0") if minute_divisors.size == 2 && minute_divisors[1].to_i <= 0
        raise error_message(minute_entry,"minute must be either an *, 0-60, or 0-60") unless minute_divisors[0] =~ /^([\*]|[0-5][0-9]?)$/
      end 
    end
  end
  def check_hour(hour_entry)
  end
  def check_day(day_entry)
  end
  def check_month(month_entry)
  end
  def check_weekday(weekday_entry)
  end
  def error_message(entry,message)
    "Error with Crontab Entry #{entry.inspect}\n#{message}\n"
  end
end

class CrontabMinute
  @@min = 0
  @@max = 59
  def initialize(start, stop=nil, step=nil)
    @start = start
    stop.nil? ? @stop = start : @stop = stop
    step.nil? ? @step = 1 : @step = step
  end
  def to_s
    as_s = @start.to_s
    as_s += "-#{@stop}" if @stop > @start
    as_s += "/#{@step}" if @step > 1
    as_s
  end
  def is_valid?
    @start >= @@min and @stop <= @@max
  end
end
