class Macroape::ScansController < ::TasksController

protected

  def default_params
    { collection: :hocomoco,
      query_background_attributes: {mode: :wordwise, gc_content: 0.5, frequencies_attributes: [0.25, 0.25, 0.25, 0.25]},
      query_attributes: { matrix: Bioinform::PWM.new( File.read(Rails.root.join('public','KLF4_f2.pwm')) ).round(3) ,
                          data_model: :PWM, effective_count: 100, pseudocount: nil },
      pvalue: 0.0005,
      similarity_cutoff: 0.05,
      precise_recalc_cutoff: 0.05,
      pvalue_boundary: :upper
    }
  end

  def task_results(ticket)
    SMBSMCore.get_content(ticket, 'task_result.txt')  if SMBSMCore.check_content(ticket, 'task_result.txt')
  end
end
