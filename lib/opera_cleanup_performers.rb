require 'opera_house_configuration'
require 'opera'

module OperaCleanupPerformers
  def perform_every(time)
    Thread.new do
      loop do
        sleep(time)
        yield
      end
    end
  end

  def tt_checker
    perform_every OperaHouseConfiguration::TICKETCONTROL_DELAY do
      ticket_service_lock.synchronize do
        @tickets_expired.each_key do |ticket|
          @tickets_sold.delete(ticket)
          delete_ticket_file(ticket)
          @log.debug("ticket removed: #{ticket}")
        end
        @tickets_expired.clear
        @tickets_sold.each_key do |ticket|
          @tickets_expired[ticket] = Time.now
          @log.debug("ticket expired: #{ticket}")
        end
      end
    end
  end 
 
  def oh_performer
    perform_every OperaHouseConfiguration::PERFORMER_DELAY do
      scene_lock.synchronize do
        if has_free_slot? && !@side_scenes.empty?
          task_to_perform = @side_scenes.shift
          @log.debug("starting #{task_to_perform.opera_name} performance | #{task_to_perform.ticket}")
          perform(task_to_perform)
        end
      end
    end
  end

  def oh_checker
    perform_every OperaHouseConfiguration::CHECKER_DELAY do
      @log.debug("theatre is open, performing operas: #{busy_slots}, free action slot: #{has_free_slot?}, side scenes opera count: #{@side_scenes.length}")
    end
  end

  def oh_cleaner
    perform_every OperaHouseConfiguration::CLEANER_DELAY do
      cleanable_lock.synchronize do
        @cleanable.each{|to_clean| clean(to_clean) }
        @cleanable.clear
      end
    end
  end
  
  def clean(ticket)
    cleaning = scene_lock.synchronize{ get_performance(ticket) }
    @log.debug("cleaning #{cleaning.inspect}")
    clean_res = cleaning.clean
    soloists_lock.synchronize{ silence_solo(@soloists.delete(ticket)) }
    @log.debug('cleaning done')
    clean_res
  end
  
  private :oh_cleaner, :oh_checker, :oh_performer, :tt_checker
end