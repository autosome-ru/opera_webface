require 'bioinform'
require 'fileutils'
require_relative '../../../app/models/model_creation'
require_relative '../../../app/models/background_form'

module ScanCollection
  def self.perform_overture(opera_status, task_params)
    File.write('task_params.yaml', task_params.to_yaml)

    background = BackgroundForm.new(task_params[:background]).background
    save_motif_in_different_types(task_params[:query], background: background, basename: 'query')

    collection_name = task_params[:collection].to_s.downcase
    FileUtils.ln_s(File.join(OperaHouseConfiguration::ASSETS_PATH, 'motif_collection', 'pwm', collection_name), 'collection')
    FileUtils.ln_s(File.join(OperaHouseConfiguration::ASSETS_PATH, 'ape.jar'), 'ape.jar')
  end
end
