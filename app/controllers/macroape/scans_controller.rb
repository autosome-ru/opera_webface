class Macroape::ScansController < ::TasksController
  def description
    redirect_to controller: '/welcome', action: 'macroape'
  end

protected
  def query_matrix_examples
    {
      pwm: Bioinform::MotifModel::PWM.from_file( Rails.root.join('public','motif_1.pwm') ),
      pcm: Bioinform::MotifModel::PCM.from_file( Rails.root.join('public','motif_1.pcm') ).rounded(precision: 0),
      ppm: Bioinform::MotifModel::PPM.from_file( Rails.root.join('public','motif_1.ppm') )
    }
  end
  helper_method :query_matrix_examples

  def default_params
    { collection: :hocomoco_10_human,
      background: BackgroundForm.uniform,
      query: DataModelForm.new(
        data_model: :PCM, effective_count: 100, pseudocount: :log,
        matrix: Bioinform::MotifModel::PCM.from_file( Rails.root.join('public','motif_1.pcm') ).rounded(precision: 0)
      ),
      pvalue: 0.0005,
      similarity_cutoff: 0.05,
      precise_recalc_cutoff: 0.05,
      pvalue_boundary: :upper
    }
  end

  def task_results(ticket)
    SMBSMCore.get_content(ticket, 'task_result.txt')  if SMBSMCore.check_content(ticket, 'task_result.txt')
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
