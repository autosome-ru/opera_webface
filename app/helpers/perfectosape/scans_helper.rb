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
      collection_motif_links(collection_name, motif)
      motif_info = motif_info(collection_name, motif) + '<br>' + collection_motif_image_link(collection_name, motif, 'direct')

      alignment = alignment_text(sequence: snp_sequences[snp_id], word: motifs[motif].consensus,
                                  orientation_1: orientation_1, position_1: pos_1.to_i,
                                  orientation_2: orientation_2, position_2: pos_2.to_i)
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

  def alignment_text(snp_infos)
    snp_sequence = SequenceWithSNP.from_string(snp_infos[:sequence])
    if snp_infos[:orientation_1] == snp_infos[:orientation_2]
      if snp_infos[:orientation_1].to_sym == :direct
        '+&nbsp;' + word_align_to_snp_sequence(snp_infos[:word], snp_infos[:position_1], snp_sequence) + "<br>" +
        '+&nbsp;' + snp_sequence.to_s + "<br>" +
        '+&nbsp;' + word_align_to_snp_sequence(snp_infos[:word], snp_infos[:position_2], snp_sequence)
      else
        '-&nbsp;' + word_align_to_snp_sequence(snp_infos[:word], -(snp_infos[:word].length - 1 + snp_infos[:position_1]), snp_sequence) + "<br>" +
        '-&nbsp;' + snp_sequence.revcomp.to_s + "<br>" +
        '-&nbsp;' + word_align_to_snp_sequence(snp_infos[:word], -(snp_infos[:word].length - 1 + snp_infos[:position_2]), snp_sequence)
      end
    else
      if snp_infos[:orientation_1].to_sym == :direct
        '+&nbsp;' + word_align_to_snp_sequence(snp_infos[:word], snp_infos[:position_1], snp_sequence) + "<br>" +
        '+&nbsp;' + snp_sequence.to_s + "<br>" +
        '-&nbsp;' + snp_sequence.complement.to_s + "<br>" +
        '-&nbsp;' + word_align_to_snp_sequence(Sequence.revcomp(snp_infos[:word]), snp_infos[:position_2], snp_sequence.complement)
      else
        '-&nbsp;' + word_align_to_snp_sequence(Sequence.revcomp(snp_infos[:word]), snp_infos[:position_1], snp_sequence.complement) + "<br>" +
        '-&nbsp;' + snp_sequence.complement.to_s + "<br>" +
        '+&nbsp;' + snp_sequence.to_s + "<br>" +
        '+&nbsp;' + word_align_to_snp_sequence(snp_infos[:word], snp_infos[:position_2], snp_sequence)
      end
    end
  end
end
