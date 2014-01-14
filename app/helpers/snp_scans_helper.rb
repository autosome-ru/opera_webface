module SnpScansHelper
  def snp_scan_table(task_results, task_params)
    header = ["SNP name", "motif", "logo", "P-value 1", "P-value 2", "Fold change", "position 1", "orientation 1", "word 1", "position 2", "orientation 2", "word 2", "allele 1/allele 2"]
    table_from_txt(task_results, task_params, header: header) do |line|
      snp_id, motif, pos_1, orientation_1, word_1, pos_2, orientation_2, word_2, alleles, pvalue_1, pvalue_2, fold_change = line
      collection_name = task_params.collection
      collection_motif_links(collection_name, motif)
      [ snp_id,
        motif + collection_motif_links(collection_name, motif),
        collection_motif_image(collection_name, motif, 'direct'),
        pvalue_1.to_f.round(5), pvalue_2.to_f.round(5),
        fold_change.to_f.round(5),
        pos_1, orientation_1, word_1, pos_2, orientation_2, word_2, alleles
      ]
    end
  end
end
