require 'opera_house_configuration'
require 'logger'

class OperaLogger < Logger
  def self.instance;  @@logger;  end

  def initialize(id)
    super(File.join(OperaHouseConfiguration::STORIES_PATH, "#{id}.log"))
    datetime_format = '%d %b %H:%M:%S'
    info("Opera House opened")
    @@logger = self
  end
end
