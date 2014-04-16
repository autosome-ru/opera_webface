require 'opera_house_configuration'
require 'support'
require 'drb'

require 'opera'
require 'opera_status'
require 'opera_scene'
require 'opera_logger'
require 'opera_cleanup_performers'
require 'synchronize_methods'
require 'yaml'

class OperaHouse
  include OperaScene
  include OperaCleanupPerformers

  create_mutex :scene_lock, :cleanable_lock, :ticket_service_lock, :finales_lock, :soloists_lock, :file_lock

  def initialize
    Thread.abort_on_exception = true

    @log = OperaLogger.new(Opera.last_ticket_number.next)

    @before_side_scenes, @side_scenes, @cleanable = [], [], []
    @tickets_sold, @tickets_expired = {}, {}
    @soloists = {}

    @ticket_service = Opera.last_ticket_number

    @actions = [OperaAction.new(OperaStatus.new(nil, OperaStatus::PERFORMANCE_FINISHED, nil)),
                OperaAction.new(OperaStatus.new(nil, OperaStatus::PERFORMANCE_FINISHED, nil))]

    # run performers
    oh_performer
    oh_checker
    oh_cleaner
    tt_checker
  end

  def OperaHouse.start
    @@service = DRb.start_service(OperaHouseConfiguration::DRubyURI, OperaHouse.new)
  end

  def perform_overture(ticket, opera_name, params)
    ### need2try .reload on params - if they are DRbUnknown - and halt
    ###puts params.reload().inspect

    @log.debug("cannot shedule unknown overture #{opera_name}") and return nil  unless Opera.opera_exist?(opera_name)
    @log.debug("setting params of #{opera_name} | #{ticket}")

    ticket_service_lock.synchronize do
      return OperaStatus.new(ticket, OperaStatus::INCORRECT_TICKET, opera_name)  unless @tickets_sold.has_key?(ticket)
      # @tickets_sold.delete(ticket)
      # @tickets_expired.delete(ticket)
    end
    setup_task(ticket, opera_name, params)
  end

  def setup_task(ticket, opera_name, params)
    new_status = OperaStatus.new(ticket, OperaStatus::PARAMS_SETUP, opera_name)
    new_status.introduction
    scene_lock.synchronize do
      @before_side_scenes.push(new_status)
      new_status.perform_overture(params)
    end
    @log.debug("task params've been set")
  end

  def perform_opera(ticket, opera_name)
    @log.debug("cannot shedule unknown opera #{opera_name}") and return nil  unless Opera.opera_exist?(opera_name)
    @log.debug("sheduling performance of #{opera_name} | #{ticket}")

    ticket_service_lock.synchronize do
      return OperaStatus.new(ticket, OperaStatus::INCORRECT_TICKET, opera_name)  unless @tickets_sold.has_key?(ticket)
      @tickets_sold.delete(ticket)
      @tickets_expired.delete(ticket)
    end

    run_task(ticket, opera_name)
  end

  def run_task(ticket, opera_name)
    # TODO: move system procedures from house to opera.rb, all in ending also
    # ENSURE THAT overture\introduction plays correctly, or it'll ruin the action-slot
    new_status = OperaStatus.new(ticket, OperaStatus::PERFORMANCE_SIDESCENES, opera_name)
    scene_lock.synchronize do
      stat = @before_side_scenes.detect{|status| status.ticket == ticket}
      #$stderr.puts "========\n#{@before_side_scenes.inspect}\n#{@side_scenes.inspect}\n==============="
      @before_side_scenes.delete(stat)
      @side_scenes.push(new_status)
      #$stderr.puts "========\n#{@before_side_scenes.inspect}\n#{@side_scenes.inspect}\n==============="
    end

    @log.debug("sheduling finished successfully")
    new_status
  end

  def tsunami
    Thread.new {
      sleep(2)
      @@service.stop_service
    }
  end

  def soloist(ticket, pid, options = {})
    @log.debug("registering soloist(#{pid}) for '#{ticket}' -- `#{options[:command]}`")
    soloists_lock.synchronize do
      silence_solo(@soloists[ticket])
      @soloists[ticket] = pid
    end
  end

  def stop_soloists;  soloists_lock.synchronize{ @soloists.keys.each{|ticket| silence_solo(@soloists.delete(ticket)) }};  end

  def ending(ticket)
    @log.debug("ending for '#{ticket}' started")

    # to be sure that the ticket always exist somewhere - on scene or finalized
    finales_lock.synchronize do
      action = nil
      scene_lock.synchronize do
        action = get_performance(ticket)
        @log.fatal("this should never happen, ending opera with unknown ticket #{ticket}") if action == nil
        action.status.finish # should be within lock!
      end

      delete_ticket_file(ticket)
      File.open(Opera.ticket_yaml_path(ticket), 'w'){|f| f << action.status.to_yaml }
    end

    cleanable_lock.synchronize do
      @log.debug("sheduled cleaning for '#{ticket}'")
      @cleanable.push(ticket)
    end
  end

  def delete_ticket_file(ticket)
    file_lock.synchronize { File.delete(Opera.ticket_xml_path(ticket)) if File.exist? Opera.ticket_xml_path(ticket) }
  end

  def get_finale(full_ticket_name)
    finales_lock.synchronize do
      ticket = File.basename(full_ticket_name)
      return nil unless File.exist?(Opera.ticket_yaml_path(ticket))
      YAML.load_file(Opera.ticket_yaml_path(ticket))
    end
  end

  @@content_lock = Mutex.new
  def get_content(ticket, what);  @@content_lock.synchronize { File.open(Opera.file_on_scene(ticket, what), 'rb', &:read) };  end
  def check_content(ticket, what);  @@content_lock.synchronize { File.size?(Opera.file_on_scene(ticket, what)) };   end
  def ping; 'pong'; end

  def get_status(ticket)
    scene_lock.synchronize {
      @side_scenes.find{|status| status.ticket == ticket } ||
      @before_side_scenes.find{|status| status.ticket == ticket } ||
      get_performance(ticket).try(&:status) || get_finale(ticket)
    }
  end


  def get_ticket
    new_ticket = nil
    ticket_service_lock.synchronize do
      new_ticket = @ticket_service.next!
      @tickets_sold[new_ticket] = Time.now
      @log.debug("created the ticket: #{new_ticket}")
    end

    new_ticket
  end

  def extend_ticket(ticket); ticket_service_lock.synchronize{ @tickets_expired.delete(ticket) }; end

  def silence_solo(pid)
    Process.kill("SIGKILL", pid) if pid
  rescue
  end

  private :silence_solo

  def check_performance(id)
    raise 'not yet implemented'
  end

  def check_finished(id)
    raise 'not yet implemented'
  end

  #def get_output(ticket)
  #  @scene.get_performing(ticket)#.pout.readlines
  #end

  #def short_solo(command)
  # @pout = IO.popen(command)
  # @pout.readlines
  # system(command)
  #end
end
