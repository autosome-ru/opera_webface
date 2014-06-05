module Perfectosape::ScansHelper
  def snp_sequences(task_params)
    @snp_sequences ||= begin
      Hash[ task_params[:snp_list].each_line.map{|line| line.strip.split }.map{|line_columns| [line_columns.first, line_columns.last] } ]
    end
  end

  def motifs(collection_name)
    @motifs ||= begin
      Hash[ Dir.glob(Rails.root.join('public/motif_collection/pwm/', collection_name.to_s, '*')).map{|filename|
        filename_wo_ext = File.basename(filename, File.extname(filename))
        [filename_wo_ext, Bioinform::PWM.new(Bioinform::MatrixParser.new.parse(File.read(filename))) ]
      }]
    end
  end

  def snp_scan_table(task_results, task_params)
    collection_name = task_params.collection
    snp_sequences = snp_sequences(task_params)
    motifs = motifs(collection_name)

    header = ["SNP name", "motif",
              "P-value 1", "P-value 2", "Fold change", "alignment",
              "position 2", "orientation 2",
              "position 2", "orientation 2",
              "allele&nbsp;1 / allele&nbsp;2"]
    lines = results_data_from_txt(task_results)
    lines = lines.map do |line|
      snp_id, motif, pos_1, orientation_1, word_1, pos_2, orientation_2, word_2, alleles, pvalue_1, pvalue_2, fold_change = line
      pvalue_1, pvalue_2 = pvalue_1.to_f, pvalue_2.to_f
      pos_1, pos_2 = pos_1.to_i, pos_2.to_i
      collection_motif_links(collection_name, motif)
      motif_info = motif_info(collection_name, motif) + '<br>' + collection_motif_image_link(collection_name, motif, 'direct')

      snp = SequenceWithSNP.from_string(snp_sequences[snp_id])
      pos = (pvalue_1 <= pvalue_2) ? pos_1 : pos_2

      alignment = highlight_TFBS(snp.variant(0), snp.left.length + pos, motifs[motif].length) + '<br>' +
                  highlight_TFBS(snp.variant(1), snp.left.length + pos, motifs[motif].length)

      [ snp_id,  motif_info,
        pvalue_1.to_f.round(5),  pvalue_2.to_f.round(5),  fold_change.to_f.round(5),
        alignment,
        pos_1, orientation_1,
        pos_2, orientation_2,
        alleles
      ]
    end
    lines = lines.sort_by do |line|
      snp_id, motif_info, pvalue_1, pvalue_2, fold_change, alignment, pos_1, orientation_1, pos_2, orientation_2, alleles = *line
      fold_change
    end
    create_table(header, lines, table_html: {class: 'colorized snp_scan_results'})
  end

  def word_align_to_snp_sequence(word, position, snp_sequence)
    word_left = word.first(-position)
    word_mid = word[-position]
    word_right = word[(-position + 1)..-1]

    shift = snp_sequence.left.size + position
    rest_length = snp_sequence.to_s.length - shift - word.length - 2*snp_sequence.number_of_variants
    # _ instead of whitespace because html eats whitespaces
    '.' * shift + word_left + '_' * snp_sequence.number_of_variants + word_mid + '_' * snp_sequence.number_of_variants + word_right + '.' * rest_length
  end

  # highlight_TFBS('ACGTtTGCA', 2, 6) --> AC<em>GTtTGC</em>A
  def highlight_TFBS(sequence, tfbs_position, length)
    sequence[0...tfbs_position] + '<span class="tfbs">' + sequence[tfbs_position, length] + '</span>' + sequence[(tfbs_position + length)..-1]
  end
end
