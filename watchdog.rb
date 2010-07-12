#!/usr/bin/ruby

### TOOD: prowl-gem benutzen
# require 'rubygems'
# require 'prowl'

# get the "Ruby Electric XML" Module
# actually it's not need because we do not parse XML

# require 'rexml/document'
# include REXML

# list of senders to fetch messages from
# senders = Array.new
senders = ['com.apple.backupd', 'SMARTReporter']

# list of severities used by syslogd
severities = { 0 => 'Emergency', 1 => 'Alert', 2 => 'Critical', 3 => 'Error', 4 => 'Warning', 5 => 'Notice', 6 => 'Info', 7 => 'Debug' }

### TODO: Implement classes for different messagepools with their own overloaded to_s()-functions to pass output to a superclass provding an unified send()-function

# represent severities provided by syslogd as hash


# fetching the syslog-output into a var we can hand over to the XML-Parser
# string = `syslog -F xml -k Sender com.apple.backupd -k Time ge -55m;`
# doc = Document.new(string)
# 
# doc.root.each_element('//dict') { |dict| dict.each_element_with_text('Message') { |lmnt| p lmnt.get_text } }

# fetching a preformatted string from syslogd
console = `syslog -F '$Sender | $Time | $Level | $Message' -k Sender com.apple.backupd -k Time ge -5m;`
# console = `syslog -F '$Time : $Level : $Message' -k Sender com.apple.backupd -k Time ge -30m;`
messages = console.split("\n")

messages.each { |message| 
  # notification =  "#{msg.split(" : ").first} #{msg.split(" : ").last}"
  token = message.split("|")
  sender = "#{token[0].strip}"
  date = "#{token[1].strip}"
  severity = severities.values_at(token[2].to_i)
  text = "#{token[3]}"
  
  if text.to_s.strip == 'Backup completed successfully.' or severity == 3
    system "/usr/local/bin/growlnotify -n #{sender} -p #{severity} -m 'Date: #{date} #{text}'"
    system "logger 'growlnotify wurde gepollt'"
  end
}