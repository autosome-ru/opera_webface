require 'opera'
require 'opera_house_configuration'
require 'support'
require 'fileutils'

class OperaStatus
  PERFORMANCE = "performance in progress"
  ALREADY_PERFORMING = "already performing"
  ALREADY_FINISHED = "already finished"
  PERFORMANCE_FINISHED = "performance finished"
  PARAMS_SETUP = "task parameters saving"
  PERFORMANCE_SIDESCENES = "performance queued in a sidescene"
  INCORRECT_TICKET = "incorrect ticket"

  attr_accessor :ticket, :message, :opera_name, :queue_time, :start_time, :end_time
  def initialize(ticket, message, opera_name)
    @ticket, @message, @opera_name = ticket, message, opera_name
    @queue_time, @start_time, @end_time  =  Time.now, nil, nil
  end

  def overture_exist?; OperaHouseConfiguration::OVERTURE_PATH.include?(@opera_name); end
  # def opera_exist?; Opera.opera_exist?(@opera_name); end
  def opera_path; OperaHouseConfiguration::OPERA_PATH[@opera_name];  end
  def overture_path; OperaHouseConfiguration::OVERTURE_PATH[@opera_name];  end
  def finish; @message, @end_time = PERFORMANCE_FINISHED, Time.now; end
  def finished?; @end_time; end
  alias_method :ended?, :finished?

  def performer_class; Object.const_get(@opera_name); end

  def perform_overture(params)
    return unless overture_exist?
    in_dir(Opera.get_new_dir(@ticket)) do
      performer_class.perform_overture(self, params)  if performer_class.respond_to?(:perform_overture)
    end
  end

  def ticket_xml_path; Opera.ticket_xml_path(@ticket); end
  def path_on_scene; Opera.path_on_scene(@ticket); end
  def ticket_xml_path_on_scene; File.join(path_on_scene, "#{@ticket}.xml"); end
  def path_to_opera_file; File.join(path_on_scene, File.basename(opera_path)); end

  def introduction
    Dir.mkdir(path_on_scene)
    #FileUtils.cp(ticket_xml_path, ticket_xml_path_on_scene)  if File.exist? ticket_xml_path
  end
end
