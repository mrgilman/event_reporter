$LOAD_PATH << './'
require 'csv'
require 'attendee'
require 'ap'

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
    when 'load' then load(parts[1])
    when 'find' then find(parts[1],parts[2])
    when 'queue' then queue(parts[1..-1])
    when 'help' then help(parts[1..-1])
    else help('help')
    end
  end

  def load(filename)
    if filename.nil?
      filename = "event_attendees.csv"
    end
    @file = CSV.open(filename, {:headers => true, :header_converters => :symbol})
    load_attendees(@file)
    puts "#{filename} loaded."
  end

  def load_attendees(file)
    self.attendees = file.collect {|line| Attendee.new(line)}
  end

  def find(attribute, criteria)
    @queue = []
    self.attendees.each do |attendee|
      if attendee.send(attribute.to_sym).downcase == criteria.downcase
        @queue << attendee
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

  def attendee_array(attendee)
    attendee_array = [
      attendee.last_name,
      attendee.first_name,
      attendee.email_address,
      attendee.zipcode,
      attendee.city,
      attendee.state,
      attendee.street]
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
    puts "LAST NAME\tFIRST NAME\tEMAIL\tZIPCODE\tCITY\tSTATE\tADDRESS"
    queue.each do |attendee|
      puts attendee_array(attendee).join("\t")
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
      output << ["LAST NAME","FIRST NAME","EMAIL","ZIPCODE","CITY","STATE","ADDRESS"]
      @queue.each do |attendee|
        output << attendee_array(attendee)
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
      puts "Available Commands:\n\tload <filename>\n\tfind <attribute> <criteria>\n\tqueue count\n\tqueue clear\n\tqueue print\n\tqueue print by <attribute>\n\tqueue save to <filename.csv>\n\tquit"
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
    else puts "Invalid help topic. Available topics:\n\tload\n\tfind\n\tqueue count\n\tqueue clear\n\tqueue print\n\tqueue print by\n\tqueue save"
    end
  end

  def load_help
    puts "load <filename>: Loads CSV file for report. Default file is event_attendees.csv."
  end

  def find_help
    puts "find <attribute> <criteria>: Finds records matching criteria for a given attribute.\nSearch results saved to queue.\nValid attributes: last_name  first_name  email  zipcode  city  state  address"
  end

  def queue_help(topic)
    topic = topic.join(" ")
    case topic
    when 'count' then puts "queue count: Counts the number of records in the current queue."
    when 'clear' then puts "queue clear: Empties the current queue."
    when 'print' then queue_print_help(topic)
    when 'save' then puts "queue save to <filename.csv>: Saves current queue to CSV."
    end
  end

  def queue_print_help(topic)
    case topic
    when 'print' then puts "queue print: Prints current queue in default order."
    when 'print by' then puts "queue print by <attribute>: Prints current queue in order by specified attribute.\nValid attributes: last_name  first_name  email  zipcode  city  state  address"
    end
  end

  def quit_help
    puts "Exits the program."
  end

end


er = EventReporter.new
er.run