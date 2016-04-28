class SnpListValidator
  SNP_PATTERN = /\A[ACGTN]*\[[ACGTN]\/[ACGTN]\][ACGTN]+\z/i

  def valid_snp_format?(line)
    seq = line.strip.split(/[[:space:]]+/, 2)[1] || ''
    seq.gsub(/[[:space:]]/, '').match(SNP_PATTERN)
  end

  def valid?(text)
    text.lines.all?{|line|
      valid_snp_format?(line)
    } && !text.lines.empty?
  end

  private :valid_snp_format?
end
