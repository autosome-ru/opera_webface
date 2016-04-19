class Chipmunk::MotifDiscoveryForm::Di < Chipmunk::MotifDiscoveryForm
  attribute :gc_content, Symbol, default: :auto
  validates :gc_content, inclusion: { in: [:auto, :uniform] }

  def self.task_type; 'MotifDiscoveryDi'; end

  private def check_sequence_list_validity
    super

    text = sequence_list.value
    fasta_records = FastaRecord.each_record(text)

    # this check differs a bit between mono and dinucleotide version
    unless fasta_records.all?{|record| record.length >= max_motif_length + 1 }
      errors.add(:sequence_list, "Motif length can't be greater than sequence length")
    end
  end
end
