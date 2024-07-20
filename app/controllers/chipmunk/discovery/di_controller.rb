require 'chipmunk_dinucleotide_result'

class Chipmunk::Discovery::DiController < Chipmunk::DiscoveryController
  private

  def task_results(ticket)
    chipmunk_output = SMBSMCore.get_content(ticket, 'task_result.txt').force_encoding('UTF-8')  if SMBSMCore.check_content(ticket, 'task_result.txt')
    ChIPMunk::Di::Result.from_chipmunk_output(chipmunk_output)
  end

  def task_logo
    'dichipmunk_logo.png'
  end

  def self.model_class
    Chipmunk::MotifDiscoveryForm::Di
  end
end
