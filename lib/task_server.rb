$:.unshift File.dirname(__FILE__)
require 'opera_house_configuration'
OperaHouseConfiguration::OVERTURE_PATH.each { |task_class, filename|  autoload(task_class, filename) }

require 'opera'
require 'opera_status'
require 'opera_action'
require 'opera_scene'
require 'opera_cleanup_performers'
require 'opera_logger'
require 'opera_soloist'
require 'opera_house'
