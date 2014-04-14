class Sequence
  attr_reader :sequence, :name
  def initialize(sequence, options = {})
    raise 'Wrong sequence' unless Sequence.valid_sequence?(sequence)
    @sequence = sequence
    @name = options[:name] || sequence
  end

  def length
    sequence.length
  end

  def revcomp
    Sequence.revcomp(sequence)
  end

  def self.complement(sequence)
    sequence.tr('acgtACGT', 'tgcaTGCA')
  end
  def self.revcomp(sequence)
    complement(sequence).reverse
  end

  def self.valid_sequence?(sequence)
    sequence.match /\A[acgt]+\z/i
  end
  def to_s
    sequence
  end
end
