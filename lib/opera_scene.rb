require 'opera_status'
require 'opera_action'

module OperaScene
  def has_free_slot?;  @actions.any?(&:free?);  end
  def busy_slots;  @actions.inject(0) { |sum, a| sum + (a.free? ? 0 : 1) };  end
  def get_performance(ticket);  @actions.find{|action| action.ticket == ticket };  end
  
  def perform(new_status)
    free_action = @actions.find(&:free?)
    raise "No free actions to perform new opera: #{new_status}, this should never happen"  unless free_action
    free_action.perform(new_status)
  end
end