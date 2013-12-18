require 'drb'

module SMBSMCore
  DRubyURI = 'druby://localhost:1111'
  TimeoutForTheatreToStart = 5
  PATH_TO_THEATER_START = 'ruby /home/ilya/programming/opera_webface/lib/opera_house_start.rb'
  
  def self.theatre; (DRb.thread && @theatre) || opera_manager;  end
  
  # setup task parameters: ticket --> params
  def self.perform_overture(ticket, name, params = {});  theatre.perform_overture(ticket, name, params);  end
  # run task by ticket number
  def self.perform_opera(ticket, name);  theatre.perform_opera(ticket, name);  end

  def self.get_ticket;  theatre.get_ticket;  end
  def self.get_status(ticket);  theatre.get_status(ticket);  end 
  def self.get_content(ticket, what);  theatre.get_content(ticket, what)  rescue nil;  end
  def self.check_content(ticket, what);  theatre.check_content(ticket, what)  rescue nil;  end

  # def self.soloist(command, ticket = $ticket)
  def self.soloist(command, ticket)
    raise 'ticket not set' unless ticket
    solo = OperaSoloist.new(command)
    theatre.soloist(ticket, solo.pid)
    solo.result
  end
  
  def self.opera_manager
    begin
      if !DRb.thread || !@theatre
        DRb.start_service
        @theatre = DRbObject.new(nil, DRubyURI)
      end  
      @theatre.ping
    rescue
      Thread.new { system(PATH_TO_THEATER_START) }
      sleep(TimeoutForTheatreToStart)
      @theatre = DRbObject.new(nil, DRubyURI)
      @theatre.ping
    end
    @theatre
  end
end