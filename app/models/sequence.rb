class Sequence
  SEQUENCE_PATTERN = /\A[ACGTN]+\z/i

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
    sequence.tr('acgtnACGTN', 'tgcanTGCAN')
  end
  def self.revcomp(sequence)
    complement(sequence).reverse
  end

  def self.valid_sequence?(sequence)
    !!sequence.match(SEQUENCE_PATTERN)
  end

  def ==(other)
    other.is_a?(IupacSequence) && other.sequence == sequence
  end

  def eql?(other)
    other.class == self.class && other.sequence == sequence
  end

  def hash
    sequence.hash
  end

  def to_s
    sequence
  end
end
