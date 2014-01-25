require 'bioinform'
require_relative '../../bioinform_support'
module EvaluateSimilarity
  def self.perform_overture(opera_status, run_params)
    File.write('task_params.yaml', run_params.to_yaml)
    File.write('pwm_first.pwm', run_params[:first_motif][:pwm])
    File.write('pwm_second.pwm', run_params[:second_motif][:pwm])
    File.write('pcm_first.pcm', run_params[:first_motif][:pcm])  if run_params[:first_motif][:pcm]
    File.write('pcm_second.pcm', run_params[:second_motif][:pcm])  if run_params[:second_motif][:pcm]
    File.write('ppm_first.ppm', run_params[:first_motif][:ppm])  if run_params[:first_motif][:ppm]
    File.write('ppm_second.ppm', run_params[:second_motif][:ppm])  if run_params[:second_motif][:ppm]
  end
end
