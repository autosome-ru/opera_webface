require 'bioinform'

def save_motif_in_different_types(model_params, background:, basename:)
  case model_params[:data_model]
  when :PCM
    pcm = Bioinform::MotifModel::PCM.from_string(model_params[:matrix])

    pcm2pwm_converter = Bioinform::ConversionAlgorithms::PCM2PWMConverter.new(background: background, pseudocount: model_params[:pseudocount])
    pwm = pcm2pwm_converter.convert(pcm)

    pcm2ppm_converter = Bioinform::ConversionAlgorithms::PCM2PPMConverter.new
    ppm = pcm2ppm_converter.convert(pcm)

  when :PPM
    ppm = Bioinform::MotifModel::PPM.from_string(model_params[:matrix])

    ppm2pcm_converter = Bioinform::ConversionAlgorithms::PPM2PCMConverter.new(count: model_params[:effective_count])
    pcm = ppm2pcm_converter.convert(ppm)

    pcm2pwm_converter = Bioinform::ConversionAlgorithms::PCM2PWMConverter.new(background: background, pseudocount: model_params[:pseudocount])
    pwm = pcm2pwm_converter.convert(pcm)
  when :PWM
    pwm = Bioinform::MotifModel::PWM.from_string(model_params[:matrix])
  end
  File.write("#{basename}.pwm", pwm)
  File.write("#{basename}.pcm", pcm) if pcm
  File.write("#{basename}.ppm", ppm) if ppm
end
