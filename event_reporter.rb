$LOAD_PATH << './'
require 'csv'
require 'attendee'

class EventReporter
  attr_accessor :attendees

  def initialize
    puts "EventReporter Initialized"
  end

  def run
    command = ""
    while command
      printf "enter command > "
      input = gets.chomp
      parts = input.split(" ")
      input_parse(parts)
    end
  end

  def input_parse(parts)
    case parts[0]
    when 'quit' then exit
    when 'exit' then exit
    when 'load' then load(parts[1])
    when 'find' then find(parts[1],parts[2..-1].join(" "))
    when 'queue' then queue(parts[1..-1])
    when 'help' then help(parts[1..-1])
    else help('help')
    end
  end

  def load(filename)
    if filename.nil?
      filename = "event_attendees.csv"
    end
    options = {:headers => true, :header_converters => :symbol}
    @file = CSV.open(filename, options)
    load_attendees(@file)
    puts "#{filename} loaded."
    @queue = []
  end

  def load_attendees(file)
    self.attendees = file.collect {|line| Attendee.new(line)}
  end

  def find(attribute, criteria)
    @queue = []
    if self.attendees.nil?
      @queue = []
    else
      self.attendees.each do |attendee|
        if attendee.send(attribute.to_sym).downcase == criteria.downcase
          @queue << attendee
        end
      end
    end
  end

  def queue(command)
    case command[0]
    when 'count' then puts @queue.count
    when 'clear' then @queue = []
    when 'print' then print_parse(command[1..-1])
    when 'save' then save(command[2])
    end
  end

  def criteria_array(attribute)
    criteria_array = []
      @queue.each do |attendee|
        criteria_array << attendee.send(attribute.to_sym)
      end
    criteria_array = criteria_array.sort_by{|criteria| criteria.length}
  end

  def longest(attribute)
    length = criteria_array(attribute).last.length + 1
    if length < attribute.length
      length = attribute.length + 1
    else
      length
    end
  end

  def header_array
    header_array =  [
      "LAST NAME ".ljust(longest("last_name")),
      "FIRST NAME ".ljust(longest("first_name")),
      "EMAIL ".ljust(longest("email_address")),
      "ZIPCODE ".ljust(8),
      "CITY ".ljust(longest("city")),
      "STATE ".ljust(6),
      "ADDRESS ".ljust(longest("street"))]
    header_array = header_array.join
  end

  def attendee_array(attendee)
    attendee_array = [
      attendee.last_name.ljust(longest("last_name")),
      attendee.first_name.ljust(longest("first_name")),
      attendee.email_address.ljust(longest("email_address")),
      attendee.zipcode.ljust(8),
      attendee.city.ljust(longest("city")),
      attendee.state.ljust(6),
      attendee.street.ljust(longest("street"))]
  end

  def attendee_array_csv(attendee)
    attendee_array_csv = [attendee.regdate, attendee.first_name,
      attendee.last_name, attendee.email_address, attendee.homephone,
      attendee.street, attendee.city, attendee.state, attendee.zipcode]
  end

  def print_parse(command)
    if command[0].nil?
      print(@queue)
    elsif command[0].downcase == "by"
      print(queue_sort(command[1]))
    else
      puts "Invalid input."
    end
  end

  def print(queue)
    if queue.count == 0
      puts "No data."
    else
      puts header_array
      queue.each do |attendee|
        puts attendee_array(attendee).join
      end
    end
  end

  def queue_sort(attribute)
    @queue.sort_by { |attendee| attendee.send(attribute.to_sym) }
  end

  def save(filename)
    if filename[-3..-1].downcase == 'csv'
      save_to_csv(filename)
    elsif filename[-3..-1].downcase == 'txt'
      save_to_txt(filename)
    else
      puts "Unsupported file extension"
    end
  end

  def save_to_csv(filename)
    output = CSV.open(filename, "w") do |output|
      output << [ "regdate", "first_name", "last_name", "email_address",
        "homephone", "street", "city", "state", "zipcode" ]
      @queue.each do |attendee|
        output << attendee_array_csv(attendee)
      end
    end
    puts "Queue saved to #{filename} in current directory."
  end

  def save_to_txt(filename)
    output = File.open(filename, "w") do |output|
      output << "LAST NAME\tFIRST NAME\tEMAIL\tZIPCODE\tCITY\tSTATE\tADDRESS\n"
      @queue.each do |attendee|
        attendee = attendee_array(attendee).join("\t") + "\n"
        output << attendee
      end
    end
    puts "Queue saved to #{filename} in current directory."
  end

  def help(topic)
    if topic[0].nil? || topic == 'help'
      printf "Available Commands:\n\tload <filename>\n\tfind <attribute>"
      printf " <criteria>\n\tqueue count\n\tqueue clear\n\tqueue print\n\t"
      printf "queue print by <attribute>\n\tqueue save to <filename.csv>\n\t"
      puts "quit"
    else
      help_topics(topic)
    end
  end

  def help_topics(topic)
    case topic[0]
    when 'load' then load_help
    when 'find' then find_help
    when 'queue' then queue_help(topic[1..-1])
    when 'quit' then quit_help
    else invalid_help_topic
    end
  end

  def load_help
    printf "load <filename>: Loads CSV file for report. Default file is "
    puts "event_attendees.csv."
  end

  def find_help
    printf "find <attribute> <criteria>: Finds records matching criteria for a"
    printf " given attribute.\nSearch results saved to queue.\nValid "
    printf "attributes: last_name  first_name  email  zipcode  city  state  "
    puts "address"
  end

  def queue_help(topic)
    topic = topic.join(" ")
    case topic
    when 'count' then printf "queue count: Counts the number of records in "
      puts "the current queue."
    when 'clear' then puts "queue clear: Empties the current queue."
    when 'print' then queue_print_help(topic)
    when 'save' then printf "queue save to <filename.csv>: Saves current "
      puts "queue to CSV."
    end
  end

  def queue_print_help(topic)
    case topic
    when 'print' then printf "queue print: Prints current queue in default "
      puts "order."
    when 'print by' then printf "queue print by <attribute>: Prints current "
      printf "queue in order by specified attribute.\nValid attributes: "
      puts "last_name  first_name  email  zipcode  city  state  address"
    end
  end

  def quit_help
    puts "Exits the program."
  end

  def invalid_help_topic
    printf "Invalid help topic. Available topics:\n\tload\n\tfind\n\t"
    printf "queue count\n\tqueue clear\n\tqueue print\n\tqueue print by\n\t"
    puts "queue save"
  end

end


er = EventReporter.new
er.run