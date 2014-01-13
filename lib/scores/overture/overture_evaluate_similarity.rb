require 'bioinform'
require_relative '../../bioinform_support'
module EvaluateSimilarity
  def self.perform_overture(opera_status, run_params)
    File.write('task_params.yaml', run_params.to_yaml)
    File.write('pwm_first.pwm', Bioinform::PWM.new(run_params[:pwm_first]).to_s)
    File.write('pwm_second.pwm', Bioinform::PWM.new(run_params[:pwm_second]).to_s)
    if run_params[:data_model_first].to_s == 'PCM'
      File.write('pcm_first.pcm', Bioinform::PCM.new(run_params[:matrix_first]).to_s)
    end
    if run_params[:data_model_second].to_s == 'PCM'
      File.write('pcm_second.pcm', Bioinform::PCM.new(run_params[:matrix_second]).to_s)
    end
    if run_params[:data_model_first].to_s == 'PPM'
      ppm = Bioinform::PPM.new(run_params[:matrix_first])
      ppm.effective_count = run_params[:effective_count_first]
      File.write('ppm_first.ppm', ppm.to_s)
      File.write('pcm_first.pcm', ppm.to_pcm.to_s)
    end
    if run_params[:data_model_second].to_s == 'PPM'
      ppm = Bioinform::PPM.new(run_params[:matrix_second])
      ppm.effective_count = run_params[:effective_count_second]
      File.write('ppm_second.ppm', ppm.to_s)
      File.write('pcm_second.pcm', ppm.to_pcm.to_s)
    end

  end
end