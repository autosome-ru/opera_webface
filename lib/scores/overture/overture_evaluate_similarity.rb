require 'bioinform'
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
  end
end