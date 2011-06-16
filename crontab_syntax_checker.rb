crontab_string+="#{crontab[:minute] || "*"} #{crontab[:hour] || "*"} #{crontab[:day] || "*"} #{crontab[:month] || "*"} #{crontab[:weekday] || "*"} #{crontab[:user] || node[:deploy_user]} #{command}\n"

def verify_crontab_entry(entry)
  check_format(entry)
  
  #check minute entry
  check_minute(entry)
end


def check_format(entry)
  [:minute,:hour,:day,:month,:weekday].each do |type|
    next if entry[type].nil?
    raise error_message(entry,"#{type} must be a string") if entry[type].class != String
    raise error_message(entry,"#{type} cannot be blank") if entry[type] == ""
    raise error_message(entry,"#{type} may only contain numbers, *, -, and /") if entry[type] !~ /^[0-9\*\-\/]+$/
    
  end
end

def error_message(entry,message)
  "Error with Crontab Entry #{entry.inspect}\n#{message}\n"
end

def check_minute(entry)
  minute_entry = entry[:minute]
  return if minute_entry.nil?
  
  minutes = minute_entry.split(",",-1)
  minutes.each do |minute|
    raise error_message(entry, "minute cannot contain a trailing comma") if minute == ""
    
    minute_ranges = minute.split("-",-1)
    raise error_message(entry,"minute cannot contain more than one '-'") if minute_ranges.size > 2
    raise error_message(entry,"minute contains an invalid range") if minute_ranges.size == 2 && minute_ranges[0].to_i > minute_ranges[1].to_i
    
    minute_ranges.each do |minute_range|
      raise error_message(entry,"minute in a range can only contain numbers") if minute_ranges.size == 2 && minute_range !~ /^[0-9]+$/
      
      minute_divisors = minute_range.split("/",-1)
      raise error_message(entry,"minute cannot contain more than one '/'") if minute_divisors.size > 2
      raise error_message(entry, "divisor must be a number greater than 0") if minute_divisors.size == 2 && minute_divisors[1].to_i <= 0
      raise error_message(entry,"minute must be either an *, 0-60, or 0-60") unless minute_divisors[0] =~ /^([\*]|[0-5][0-9]?)$/
    end 
  end
end