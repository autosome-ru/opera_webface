require 'bioinform'
require_relative '../../bioinform_support'
require 'fileutils'
module ScanCollection
  def self.perform_overture(opera_status, run_params)
    File.write('task_params.yaml', run_params.to_yaml)
    File.write('query.pwm', Bioinform::PWM.new(run_params[:query_pwm]))

    background = run_params[:background]

    query_data_model = run_params[:query_data_model].to_s
    query_matrix = run_params[:query_matrix]
    query_effective_count = run_params[:query_effective_count]

    if %w[PCM PPM].include?(query_data_model)
      pcm = Bioinform.get_pcm(query_data_model, query_matrix, background, query_effective_count)
      File.write('query.pcm', pcm)
    end

    if %w[PPM].include?(query_data_model)
      ppm = Bioinform::PPM.new(query_matrix)
      File.write('query.ppm', ppm)
    end

    collection_name = run_params[:collection].to_s.downcase
    FileUtils.ln_s(File.join(OperaHouseConfiguration::ASSETS_PATH, 'motif_collection', 'pwm', collection_name), 'collection')
    FileUtils.ln_s(File.join(OperaHouseConfiguration::ASSETS_PATH, 'motif_collection', 'thresholds', collection_name), 'collection_precalc')
    FileUtils.ln_s(File.join(OperaHouseConfiguration::ASSETS_PATH, 'scan-collection.jar'), 'scan-collection.jar')

  end
end
