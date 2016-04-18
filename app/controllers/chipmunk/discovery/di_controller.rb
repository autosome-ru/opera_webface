require 'chipmunk_dinucleotide_result'

class Chipmunk::Discovery::DiController < Chipmunk::DiscoveryController
  def task_results(ticket)
    chipmunk_output = SMBSMCore.get_content(ticket, 'task_result.txt')  if SMBSMCore.check_content(ticket, 'task_result.txt')
    @chipmunk_infos = ChIPMunk::Di::Result.from_chipmunk_output(chipmunk_output)
  end

  def task_logo
    'dichipmunk_logo.png'
  end

  def self.model_class
    Chipmunk::MotifDiscoveryForm::Di
  end
end
