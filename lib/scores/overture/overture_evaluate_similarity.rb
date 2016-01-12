require 'bioinform'
require_relative '../../../app/models/model_creation'
require_relative '../../../app/models/background_form'

module EvaluateSimilarity
  def self.perform_overture(opera_status, task_params)
    File.write('task_params.yaml', task_params.to_yaml)

    background = BackgroundForm.new(task_params[:background]).background
    save_motif_in_different_types(task_params[:first_motif], background: background, basename: 'first')
    save_motif_in_different_types(task_params[:second_motif], background: background, basename: 'second')

    FileUtils.ln_s(File.join(OperaHouseConfiguration::ASSETS_PATH, 'ape.jar'), 'ape.jar')
  end
end
