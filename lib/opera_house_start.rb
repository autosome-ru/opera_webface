t = Time.now
$:.unshift File.dirname(__FILE__)
require 'task_server'

OperaHouse.start
OperaLogger.instance.info 'Opera House started'
puts "Opera House started in #{Time.now - t} sec"
DRb.thread.join
