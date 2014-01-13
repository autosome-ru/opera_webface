require 'bioinform'
require 'fileutils'
module SnpScan
  def self.perform_overture(opera_status, run_params)
    File.write('task_params.yaml', run_params.to_yaml)
    File.write('snp_list.txt', run_params[:snp_list])
    FileUtils.ln_s(File.join(OperaHouseConfiguration::ASSETS_PATH, 'multi-SNP-scan.jar'), 'multi-SNP-scan.jar')
    case run_params[:collection].to_s.downcase
    when 'hocomoco'
      FileUtils.ln_s(File.join(OperaHouseConfiguration::ASSETS_PATH, 'hocomoco_ad_uniform_v9'), 'collection')
      FileUtils.ln_s(File.join(OperaHouseConfiguration::ASSETS_PATH, 'hocomoco_ad_uniform_v9_precalc'), 'collection_precalc')
    end
  end
end
