require Rails.root.join('app/models/data_model')

class Macroape::ComparesController < ::TasksController
  def description
    redirect_to controller: '/welcome', action: 'macroape'
  end

protected
  def first_matrix_examples
    pcm = Bioinform::MotifModel::PCM.from_file( Rails.root.join('public','motif_1.pcm') )
    {
      pwm: Bioinform::MotifModel::PWM.from_file( Rails.root.join('public','motif_1.pwm') ),
      pcm: Bioinform::MotifModel::PCM.new(pcm.matrix_rounded(0)).named(pcm.name),
      ppm: Bioinform::MotifModel::PPM.from_file( Rails.root.join('public','motif_1.ppm') )
    }
  end
  def second_matrix_examples
    {
      pwm: Bioinform::MotifModel::PWM.from_file( Rails.root.join('public','motif_2.pwm') ),
      pcm: Bioinform::MotifModel::PCM.from_file( Rails.root.join('public','motif_2.pcm') ),
      ppm: Bioinform::MotifModel::PPM.from_file( Rails.root.join('public','motif_2.ppm') )
    }
  end
  helper_method :first_matrix_examples
  helper_method :second_matrix_examples
  def default_params
    pcm_1 = Bioinform::MotifModel::PCM.from_file( Rails.root.join('public','motif_1.pcm') )
    { background_attributes: {mode: :wordwise, frequencies_attributes: [0.25, 0.25, 0.25, 0.25], gc_content: 0.5},
      pvalue: 0.0005,
      discretization: 10,
      pvalue_boundary: :upper,
      first_motif_attributes: {
        data_model: :PCM, effective_count: 100, pseudocount: nil,
        matrix: Bioinform::MotifModel::PCM.new(pcm_1.matrix_rounded(0)).named(pcm_1.name)
      },
      second_motif_attributes: {
        data_model: :PCM, effective_count: 100, pseudocount: nil,
        matrix: Bioinform::MotifModel::PCM.from_file( Rails.root.join('public','motif_2.pcm') )
      }
    }
  end

  def task_logo
    'macroape_logo.png'
  end
end
