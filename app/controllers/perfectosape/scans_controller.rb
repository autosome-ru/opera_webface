class Perfectosape::ScansController < ::TasksController
  protected

  def default_params
    test_snps = <<-EOS
rs10040172 gatttgccctgattgcagttactga[G/A]tggtacagacatcgtaataatctta
rs10116271 taaattctatgtggggaagaggtct[C/T]gtagaggcgatgattcttacattgc
rs10208293 cttcatacatttatgtccagtacct[A/G]tggaccctccttgtgaactcttctc
rs10431961 tggcggggctggtcaggcggcgtcg[C/T]cggtacgctctgagcggcagcgtgt
    EOS

    { snp_list: test_snps,
      # background_attributes: {mode: :wordwise, frequencies_attributes: [0.25, 0.25, 0.25, 0.25], gc_content: 0.5 },
      collection: :hocomoco,
      pvalue_cutoff: 0.0005,
      fold_change_cutoff: 5
    }
  end

  def task_results(ticket)
    SMBSMCore.get_content(ticket, 'task_result.txt')  if SMBSMCore.check_content(ticket, 'task_result.txt')
  end
end
