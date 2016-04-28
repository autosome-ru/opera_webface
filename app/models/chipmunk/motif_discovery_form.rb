require 'virtus'
require 'active_model'
require 'bioinform'
require_relative '../task_form'
require_relative '../../validators/recursive_valid_validator'
require_relative '../../validators/motif_collection_validator'
require_relative '../../validators/snp_list_validator'

class Chipmunk::MotifDiscoveryForm
  include ActiveModel::Model
  include Virtus.model(nullify_blank: true)
  include TaskForm

  attribute :sequence_list_text, String
  attribute :sequence_list_file, IO, default: nil # `default` is necessary because otherwise `IO.new` will be invoked (without arguments it raises)

  attribute :max_motif_length, Integer, default: 15
  attribute :min_motif_length, Integer, default: 6
  attribute :sequence_weighting_mode, Symbol, default: :simple
  attribute :occurences_per_sequence, Symbol, default: :oops
  attribute :motif_shape_prior, Symbol, default: :flat
  attribute :speed_mode, Symbol, default: :fast
  attribute :gc_content, Symbol, default: :auto

  validates :max_motif_length, numericality: true, inclusion: { in: 5..22 }
  validates :min_motif_length, numericality: true, inclusion: { in: 5..22 }
  validate :check_min_motif_length_not_greater_than_max

  validates :sequence_weighting_mode, inclusion: { in: [:simple, :peak, :weighted] }
  validate :check_sequence_list_validity_text_or_file

  validates :occurences_per_sequence, inclusion: { in: [:oops, :zoops] }
  validates :gc_content, inclusion: { in: [:auto, :uniform] }
  validates :motif_shape_prior, inclusion: { in: [:flat, :single, :double] }
  validates :speed_mode, inclusion: { in: [:fast, :precise] }

  def task_attributes
    result = attributes.reject{|attr_name, attr_value|
      [:sequence_list_text, :sequence_list_file].include?(attr_name)
    }.merge(sequence_list: sequence_list)
  end

  def sequence_list
    @sequence_list ||= sequence_list_file ? sequence_list_file.read : sequence_list_text
  end

  def self.task_type; 'MotifDiscovery'; end

  private def check_min_motif_length_not_greater_than_max
    unless min_motif_length <= max_motif_length
      errors.add(:min_motif_length, 'should be not greater than max motif length')
      errors.add(:max_motif_length, 'should be not less than min motif length')
    end
  end

  private def check_sequence_list_validity_text_or_file
    if sequence_list_file
      check_sequence_list_validity(:sequence_list_file, sequence_list)
    else
      check_sequence_list_validity(:sequence_list_text, sequence_list)
    end
  end

  private def check_sequence_list_validity(sequence_list_attribute, sequence_list_value)
    errors.add(sequence_list_attribute, 'No sequences provided')  if sequence_list_value.blank?
    errors.add(sequence_list_attribute, 'Sequences are not a valid multi-FASTA')  unless FastaRecord.all_records_valid?(sequence_list_value)

    fasta_records = FastaRecord.each_record(sequence_list_value)

    errors.add(sequence_list_attribute, "Specify at least two sequences")  unless fasta_records.size >= 2

    unless fasta_records.all?{|record|  IupacSequence.valid_sequence?(record.sequence)  }
      errors.add(sequence_list_attribute, 'Sequences are not IUPAC sequences')
    end

    unless fasta_records.map(&:length).inject(0, &:+) <= 102400
      errors.add(sequence_list_attribute, "Total length of sequences in web version can't be greater than 102400 bp")
    end

    case sequence_weighting_mode
    when :simple
      # pass
    when :weighted
      errors.add(sequence_list_attribute, "Header of each sequence should be a weight")  unless fasta_records.all?{|record| Float(record.header) rescue false }
    when :peak
      errors.add(sequence_list_attribute, "Header of each sequence should be a list of weights (one weight for each nucleotide)")  unless fasta_records.all?{|record|
        weights = record.header.split
        weights.length == record.length && weights.all?{|value| Float(value) rescue false }
      }
    else
      errors.add(:sequence_weighting_mode, "Unknown weighting mode")
    end
  end
end
