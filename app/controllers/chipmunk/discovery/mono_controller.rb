require 'chipmunk_result'

class Chipmunk::Discovery::MonoController < Chipmunk::DiscoveryController
  private

  def default_params
    result = super
    result[:gc_content] = 0.5  if result[:gc_content] && result[:gc_content].to_s.downcase == 'uniform'
    result
  end

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
