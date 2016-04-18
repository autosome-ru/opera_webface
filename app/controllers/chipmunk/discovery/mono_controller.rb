require 'chipmunk_result'

class Chipmunk::Discovery::MonoController < Chipmunk::DiscoveryController
  def task_results(ticket)
    chipmunk_output = SMBSMCore.get_content(ticket, 'task_result.txt')  if SMBSMCore.check_content(ticket, 'task_result.txt')
    @chipmunk_infos = ChIPMunk::Result.from_chipmunk_output(chipmunk_output)
  end

  def task_logo
    'chipmunk_logo.png'
  end

  def self.model_class
    Chipmunk::MotifDiscoveryForm::Mono
  end
end
