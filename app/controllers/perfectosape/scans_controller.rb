class Perfectosape::ScansController < ::TasksController
  def description
    redirect_to controller: '/welcome', action: 'perfectosape'
  end

  protected

  def default_params
    test_snps = <<-EOS
rs10040172 gatttgccctgattgcagttactga[G/A]tggtacagacatcgtaataatctta
rs10116271 taaattctatgtggggaagaggtct[C/T]gtagaggcgatgattcttacattgc
rs10208293 cttcatacatttatgtccagtacct[A/G]tggaccctccttgtgaactcttctc
rs10431961 tggcggggctggtcaggcggcgtcg[C/T]cggtacgctctgagcggcagcgtgt
    EOS

    { snp_list_text: test_snps,
      collection: :hocomoco_12_rsnp_hq,
      pvalue_cutoff: 0.0005,
      fold_change_cutoff: 4
    }
  end

  def task_results(ticket)
    SMBSMCore.get_content(ticket, 'task_result.txt').force_encoding('UTF-8')  if SMBSMCore.check_content(ticket, 'task_result.txt')
  end

  def task_logo
    'perfectosape_logo.png'
  end

  def self.model_class
    Perfectosape::ScanForm
  end
end
