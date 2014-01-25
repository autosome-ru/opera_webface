require 'bioinform'
require 'fileutils'
module SnpScan
  def self.perform_overture(opera_status, run_params)
    File.write('task_params.yaml', run_params.to_yaml)
    File.write('snp_list.txt', run_params[:snp_list])
    collection_name = run_params[:collection].to_s.downcase
    FileUtils.ln_s(File.join(OperaHouseConfiguration::ASSETS_PATH, 'motif_collection', 'pwm', collection_name), 'collection')
    FileUtils.ln_s(File.join(OperaHouseConfiguration::ASSETS_PATH, 'motif_collection', 'thresholds', collection_name), 'collection_precalc')
    FileUtils.ln_s(File.join(OperaHouseConfiguration::ASSETS_PATH, 'multi-SNP-scan.jar'), 'multi-SNP-scan.jar')
  end
end
