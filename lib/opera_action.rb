## TODO: sync on perform and obtain free actions. May be it's done at run level in cleanup_perfomers module but it'd be better to place it nearer to implementaton

require 'forwardable'
require 'opera_status'
require 'opera_logger'

class OperaAction
  extend Forwardable
  attr_accessor :status, :p, :pout, :pid
  def_delegators :@status,  :path_to_opera_file, :ticket_xml_path_on_scene, :ticket, :opera_path, :message
  
  def initialize(opera_status)
    @status = opera_status
  end
  
  def clean
    OperaLogger.instance.fatal("uninitialized OperaAction on clearing process") unless @pout && @p
    @pout.readlines # flushes pipe
    @pout.close_read
    @p = nil
    @status.message = OperaStatus::PERFORMANCE_FINISHED
    @status
  end
  
  def free?;  @p.nil?;  end
  def need_cleaning?;  !@p.nil?;  end
  
  def create_opera_file
    File.open(path_to_opera_file, 'w') do |f|
      f << <<-EOS
        $:.unshift '#{OperaHouseConfiguration::OPERAHOUSE_PATH}'
        require 'opera'
        ticket = '#{ticket}'
        Dir.chdir('#{File.dirname(path_to_opera_file)}')
        begin
          #{File.read(opera_path)}
        ensure
          Opera.ending(ticket)
        end
      EOS
    end
  end
  
  def inner_perform
    #TODO: ENSURE FINISHING AND CLEANING, VERY IMPORTANT!
    @p = Thread.new do
      create_opera_file  # why to create file in thread?
      ###  OperaLogger.instance.debug("opera file #{path_to_opera_file} created")
      @pout = IO.popen("ruby #{path_to_opera_file}")
    end
  end
  
  def perform(new_status)
    @status = new_status
    @status.start_time = Time.now
    @status.message = OperaStatus::PERFORMANCE
    inner_perform
  end
  
end