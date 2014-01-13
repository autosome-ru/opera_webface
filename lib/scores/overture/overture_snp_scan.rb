require 'bioinform'
require 'fileutils'
module SNPScan
  def self.perform_overture(opera_status, run_params)
    File.write('task_params.yaml', run_params.to_yaml)
    File.write('snp_sequences.txt', run_params[:snp_sequences])
  end
end
