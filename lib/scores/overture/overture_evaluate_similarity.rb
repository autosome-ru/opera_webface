require 'bioinform'
require_relative '../../bioinform_support'
module EvaluateSimilarity
  def self.perform_overture(opera_status, run_params)
    File.write('task_params.yaml', run_params.to_yaml)
    File.write('pwm_first.pwm', Bioinform::PWM.new(run_params[:pwm_first]))
    File.write('pwm_second.pwm', Bioinform::PWM.new(run_params[:pwm_second]))

    background = run_params[:background]

    data_model_first = run_params[:data_model_first].to_s
    matrix_first = run_params[:matrix_first]
    effective_count_first = run_params[:effective_count_first]

    data_model_second = run_params[:data_model_second].to_s
    matrix_second = run_params[:matrix_second]
    effective_count_second = run_params[:effective_count_second]

    if %w[PCM PPM].include?(data_model_first)
      pcm = Bioinform.get_pcm(data_model_first, matrix_first, background, effective_count_first)
      File.write('pcm_first.pcm', pcm)
    end
    if %w[PCM PPM].include?(data_model_second)
      pcm = Bioinform.get_pcm(data_model_second, matrix_second, background, effective_count_second)
      File.write('pcm_second.pcm', pcm)
    end

    if %w[PPM].include?(data_model_first)
      ppm = Bioinform::PPM.new(matrix_first)
      File.write('ppm_first.ppm', ppm)
    end
    if %w[PPM].include?(data_model_second)
      ppm = Bioinform::PPM.new(matrix_second)
      File.write('ppm_second.ppm', ppm)
    end

  end
end