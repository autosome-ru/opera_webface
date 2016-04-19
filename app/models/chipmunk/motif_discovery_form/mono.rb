class Chipmunk::MotifDiscoveryForm::Mono < Chipmunk::MotifDiscoveryForm
  attribute :gc_content, Object, default: :auto

  def gc_content=(value)
    if !value || value.blank? || value.to_s.downcase == 'auto'
      super(:auto)
    elsif !value || value.blank? || value.to_s.downcase == 'uniform'
      super(0.5)
    else
      val = Float(value) rescue value
      super(val)
    end
  end

  def self.task_type; 'MotifDiscovery'; end

  private def check_sequence_list_validity
    super

    text = sequence_list.value
    fasta_records = FastaRecord.each_record(text)

    # this check differs a bit between mono and dinucleotide version
    unless fasta_records.all?{|record| record.length >= max_motif_length }
      errors.add(:sequence_list, "Motif length can't be greater than sequence length")
    end
  end
end
