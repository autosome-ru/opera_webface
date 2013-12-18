require 'bioinform'
require 'fileutils'
module ScanCollection
  def self.perform_overture(opera_status, run_params)
    File.write('task_params.yaml', run_params.to_yaml)
    File.write('query.pwm', Bioinform::PWM.new(run_params[:query_pwm]).to_s)
    if run_params[:query_data_model].to_s == 'PCM'
      File.write('query.pcm', Bioinform::PCM.new(run_params[:query_matrix]).to_s)
    end
    if run_params[:collection_background].to_s == 'hg19'
      FileUtils.cp(File.join(OperaHouseConfiguration::ASSETS_PATH, 'hocomoco_ad_hg19.yaml'), 'collection.yaml')
    else
      FileUtils.cp(File.join(OperaHouseConfiguration::ASSETS_PATH, 'hocomoco_ad_uniform.yaml'), 'collection.yaml')
    end
  end
end
