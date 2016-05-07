class Macroape::ComparesController < ::TasksController
  def description
    redirect_to controller: '/welcome', action: 'macroape'
  end

protected
  def first_matrix_examples
    {
      pwm: Bioinform::MotifModel::PWM.from_file( Rails.root.join('public','motif_1.pwm') ),
      pcm: Bioinform::MotifModel::PCM.from_file( Rails.root.join('public','motif_1.pcm') ).rounded(precision: 0),
      ppm: Bioinform::MotifModel::PPM.from_file( Rails.root.join('public','motif_1.ppm') )
    }.map{|k,v| [k, v.to_s] }.to_h
  end
  def second_matrix_examples
    {
      pwm: Bioinform::MotifModel::PWM.from_file( Rails.root.join('public','motif_2.pwm') ),
      pcm: Bioinform::MotifModel::PCM.from_file( Rails.root.join('public','motif_2.pcm') ),
      ppm: Bioinform::MotifModel::PPM.from_file( Rails.root.join('public','motif_2.ppm') )
    }.map{|k,v| [k, v.to_s] }.to_h
  end
  helper_method :first_matrix_examples
  helper_method :second_matrix_examples
  def default_params
    { background: BackgroundForm.uniform,
      pvalue: 0.0005,
      discretization: 10,
      pvalue_boundary: :upper,
      first_motif: {
        data_model: :PCM, effective_count: 100, pseudocount: nil,
        matrix: Bioinform::MotifModel::PCM.from_file( Rails.root.join('public','motif_1.pcm') ).rounded(precision: 0)
      },
      second_motif: {
        data_model: :PCM, effective_count: 100, pseudocount: nil,
        matrix: Bioinform::MotifModel::PCM.from_file( Rails.root.join('public','motif_2.pcm') )
      }
    }
  end

  def task_results(ticket)
    results_text = SMBSMCore.get_content(ticket, 'task_result.txt')  if SMBSMCore.check_content(ticket, 'task_result.txt')
    
    infos = results_text.lines.reject{|line|
      line.start_with?('#')
    }.map{|line|
      line.chomp.split("\t")
    }.to_h

    OpenStruct.new({
      similarity: infos['S'].to_f,
      distance: infos['D'].to_f,
      alignment_length: infos['L'].to_f,
      shift: infos['SH'].to_i,
      orientation: infos['OR'].to_sym,
      alignment_first: infos['A1'],
      alignment_second: infos['A2'],
      words_common: infos['W'],
      words_first: infos['W1'],
      words_second: infos['W2'],
      pvalue_first: infos['P1'],
      pvalue_second: infos['P2'],
      threshold_first: infos['T1'],
      threshold_second: infos['T2'],
      first_pwm: Bioinform::MotifModel::PWM.from_string(SMBSMCore.get_content(ticket, 'first.pwm')),
      second_pwm: Bioinform::MotifModel::PWM.from_string(SMBSMCore.get_content(ticket, 'second.pwm')),
    })
  end

  def task_logo
    'macroape_logo.png'
  end

  def self.model_class
    Macroape::CompareForm
  end
end
