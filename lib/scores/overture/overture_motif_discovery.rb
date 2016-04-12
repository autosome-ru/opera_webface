require 'fileutils'
module MotifDiscovery
  def self.perform_overture(opera_status, task_params)
    File.write('task_params.yaml', task_params.to_yaml)
    File.write('sequences.mfa', task_params[:sequence_list])
    FileUtils.ln_s(File.join(OperaHouseConfiguration::ASSETS_PATH, 'chipmunk.jar'), 'chipmunk.jar')
  end
end
