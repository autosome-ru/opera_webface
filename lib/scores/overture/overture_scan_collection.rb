require 'bioinform'
require 'fileutils'

module ScanCollection
  def self.perform_overture(opera_status, run_params)
    File.write('task_params.yaml', run_params.to_yaml)
    File.write('query.pwm', run_params[:query][:pwm])
    File.write('query.pcm', run_params[:query][:pcm])  if run_params[:query][:pcm]
    File.write('query.ppm', run_params[:query][:ppm])  if run_params[:query][:ppm]

    collection_name = run_params[:collection].to_s.downcase
    FileUtils.ln_s(File.join(OperaHouseConfiguration::ASSETS_PATH, 'motif_collection', 'pwm', collection_name), 'collection')
    FileUtils.ln_s(File.join(OperaHouseConfiguration::ASSETS_PATH, 'motif_collection', 'thresholds', collection_name), 'collection_precalc')
    FileUtils.ln_s(File.join(OperaHouseConfiguration::ASSETS_PATH, 'scan-collection.jar'), 'scan-collection.jar')
  end
end
