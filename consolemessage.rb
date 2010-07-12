class Consolemessage
  def initialize(name,sender,pattern, condition)
    @name       = set_name(name)
    @sender     = set_sender(sender)
    @pattern    = set_pattern(pattern)
    @condition  = set_condition(condition)
    @severity   = NIL
    @message    = NIL
    ### TODO: externaliize @severities into superclass
    @severities = { 0 => 'Emergency', 1 => 'Alert', 2 => 'Critical', 3 => 'Error', 4 => 'Warning', 5 => 'Notice', 6 => 'Info', 7 => 'Debug' }
  end

  # methods to run on Consolemessage object
  def get_name
    return @name
  end

  def set_name(name)
    @name = name
  end

  def get_sender
    return "#{@name}: #{@sender}"
  end

  def set_sender(sender)
    @sender = sender
  end
  
  def get_pattern
    return @pattern
  end
  
  def set_pattern(pattern)
    @pattern = pattern
  end
  
  def get_severity
    return @severities.values_at(@severity).to_s
  end

  def set_severity(severity)
    @severity = severity
  end
  
  def get_condition
    return @condition
  end
  
  def set_condition(condition)
    @condition = condition
  end

  def get_message
    return @message
  end

  def set_message()
    # fetching a preformatted string from syslogd
    console = `syslog -F '$Sender | $Time | $Level | $Message' -k Sender #{@sender} #{@pattern};`
    p console
    # console = `syslog -F '$Time : $Level : $Message' -k Sender com.apple.backupd -k Time ge -30m;`
    messages = console.split("\n")

    messages.each { |message| 
      # notification =  "#{msg.split(" : ").first} #{msg.split(" : ").last}"
      token     = message.split("|")
      date      = token[0].strip
      severity  = set_severity(token[2].to_i)
      text      = "#{token[3]}"

      # send("-n #{@sender} -p #{severity} -m '(#{date})' #{text}")
      @message = ("-n #{@sender} -m '(#{date})' #{text}")

      # if text.to_s.strip == 'Backup completed successfully.' or severity == 3
      #   return "-n #{@sender} -p #{severity} -m '(#{date})' #{text}"
      # else
      #   return false
      # end
    }
  end

  def get_severities
    return @severities.each_pair {|key, value| p "#{key} is #{value}" }
  end

  def send
    message = get_message
    system "/usr/local/bin/growlnotify #{message}"
  end

  def system_log_message(message = "script was called")
    system "logger '#{message}'"
  end
end

# Do something with the class  
  #firewall = Consolemessage.new('Firewall', 'Firewall')
  # p firewall.get_sender
  
  smartreporter = Consolemessage.new('SMARTReporter', 'SMARTReporter', '-k Time ge -55m', NIL)
  # p smartreporter.get_sender
  # p smartreporter.get_pattern
  # p smartreporter.get_condition
  # smartreporter.set_severity(6)
  # smartreporter.get_severity
  smartreporter.set_message()
  p smartreporter.get_severity
  smartreporter.get_message