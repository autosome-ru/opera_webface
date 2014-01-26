require 'drb'
require 'opera_house_configuration'
require 'opera_soloist'
require 'support'

module Opera
  def self.path_on_scene(ticket); File.join(OperaHouseConfiguration::SCENE_PATH, ticket); end
  def self.get_new_dir(ticket);  ticket ? path_on_scene(ticket) : '.';  end
  def self.last_ticket_number;  File.basename(Dir[ path_on_scene('*') ].sort.last || 'aaaaaaaaaa').scan(/\w+/)[0];  end
  def self.opera_exist?(opera_name); OperaHouseConfiguration::OPERA_PATH.include?(opera_name); end

  def self.ending(ticket)
    return unless ticket
    DRb.start_service
    DRbObject.new(nil, OperaHouseConfiguration::DRubyURI).ending(ticket)
  end

  def self.ticket_xml_path(ticket); File.join(OperaHouseConfiguration::TICKETS_PATH, "#{ticket}.xml"); end
  def self.ticket_yaml_path(ticket); File.join(OperaHouseConfiguration::TICKETS_PATH, "#{ticket}.yaml"); end
  def self.file_on_scene(ticket, what); File.join(path_on_scene(ticket), File.basename(what)); end

  def self.get_content(ticket, what)
    File.open(file_on_scene(File.basename(ticket),what), 'rb', &:read)
  end

  #def self.short_solo(command)
  #  DRb.start_service
  #  oh = DRbObject.new(nil, OperaHouseConfiguration::DRubyURI)
  #  return oh.short_solo(command)
  #end
end
