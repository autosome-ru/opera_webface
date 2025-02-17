class Macroape::ScansController < ::TasksController
  def description
    redirect_to controller: '/welcome', action: 'macroape'
  end

protected
  def query_matrix_examples
    {
      PWM: Bioinform::MotifModel::PWM.from_file( Rails.root.join('public','motif_1.pwm') ),
      PCM: Bioinform::MotifModel::PCM.from_file( Rails.root.join('public','motif_1.pcm') ).rounded(precision: 0),
      PPM: Bioinform::MotifModel::PPM.from_file( Rails.root.join('public','motif_1.ppm') )
    }
  end
  helper_method :query_matrix_examples

  def default_params
    common_options = { collection: :hocomoco_13_core,
      background: BackgroundForm.uniform,
      query: DataModelForm.new(
        effective_count: 100, pseudocount: :log,
      ),
      pvalue: 0.0005,
      similarity_cutoff: 0.05,
      precise_recalc_cutoff: 0.05,
      pvalue_boundary: :upper
    }
    data_model = (params[:example] || :PCM).to_sym
    specific_query_options = { data_model: data_model,  matrix: query_matrix_examples[ data_model ] }
    common_options.deep_merge({query: specific_query_options})
  end

  def task_results(ticket)
    SMBSMCore.get_content(ticket, 'task_result.txt').force_encoding('UTF-8')  if SMBSMCore.check_content(ticket, 'task_result.txt')
  end

  def reload_page_time
    30
  end

  def task_logo
    'macroape_logo.png'
  end

  def self.model_class
    Macroape::ScanForm
  end
end
