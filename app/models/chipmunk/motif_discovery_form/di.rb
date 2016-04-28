class Chipmunk::MotifDiscoveryForm::Di < Chipmunk::MotifDiscoveryForm
  def self.task_type; 'MotifDiscoveryDi'; end

  private def check_sequence_list_validity(sequence_list_attribute, sequence_list_value)
    super
    fasta_records = FastaRecord.each_record(sequence_list_value)
    # this check differs a bit between mono and dinucleotide version
    unless fasta_records.count{|record| record.length >= max_motif_length + 1 } >= 2
      errors.add(sequence_list_attribute, "At least two sequences should have length greater than or equal to maximal motif length")
    end
  end
end
