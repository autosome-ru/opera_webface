require Rails.root.join('app/models/data_model')

class Macroape::ScansController < ::TasksController
  def description
    redirect_to controller: '/welcome', action: 'macroape'
  end

protected
  def query_matrix_examples
    pcm = Bioinform::PCM.new( File.read(Rails.root.join('public','motif_1.pcm')) )
    {
      pwm: Bioinform::PWM.new( File.read(Rails.root.join('public','motif_1.pwm')) ),
      pcm: Bioinform::PCM.new(matrix: pcm.matrix_rounded(0), name: pcm.name),
      ppm: Bioinform::PPM.new( File.read(Rails.root.join('public','motif_1.ppm')) )
    }
  end
  helper_method :query_matrix_examples

  def default_params
    pcm = Bioinform::PCM.new( File.read(Rails.root.join('public','motif_1.pcm')) )
    { collection: :hocomoco,
      query_background_attributes: {mode: :wordwise, gc_content: 0.5, frequencies_attributes: [0.25, 0.25, 0.25, 0.25]},
      query_attributes: { matrix: Bioinform::PCM.new(matrix: pcm.matrix_rounded(0), name: pcm.name),
                          data_model: :PCM, effective_count: 100, pseudocount: nil },
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
end
