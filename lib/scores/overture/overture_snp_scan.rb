require 'bioinform'
require 'fileutils'
module SnpScan
  def self.perform_overture(opera_status, task_params)
    File.write('task_params.yaml', task_params.to_yaml)
    File.write('snp_list.txt', task_params[:snp_list])
    collection_name = task_params[:collection].to_s.downcase
    FileUtils.ln_s(File.join(OperaHouseConfiguration::ASSETS_PATH, 'motif_collection', 'pwm', collection_name), 'collection')
    FileUtils.ln_s(File.join(OperaHouseConfiguration::ASSETS_PATH, 'motif_collection', 'thresholds', collection_name), 'collection_precalc')
    FileUtils.ln_s(File.join(OperaHouseConfiguration::ASSETS_PATH, 'ape.jar'), 'ape.jar')
  end
end
