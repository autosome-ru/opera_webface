require_relative 'sequence'

class SequenceWithSNP
  attr_reader :left, :allele_variants, :right, :name
  def initialize(left, allele_variants, right, options = {})
    raise unless Sequence.valid_sequence?(left)
    raise unless Sequence.valid_sequence?(right)
    raise unless allele_variants.all?{|letter| %w[A C G T].include?(letter.upcase) }
    @left, @allele_variants, @right = left, allele_variants, right
    @name = options[:name] || (left + '_' + allele_variants.join('-') + '_' + right)
  end

  def self.from_string(sequence, options = {})
    left, mid, right = sequence.split(/[\[\]]/)
    allele_variants = mid.split('/')
    SequenceWithSNP.new(left, allele_variants, right, options)
  end

  def length
    left.length + 1 + right.length
  end

  def reverse
    SequenceWithSNP.new(Sequence.reverse(right), allele_variants, Sequence.reverse(left), name: name)
  end
  def complement
    SequenceWithSNP.new(Sequence.complement(left), allele_variants.map{|letter| Sequence.complement(letter) }, Sequence.complement(right), name: name)
  end
  def revcomp
    SequenceWithSNP.new(Sequence.revcomp(right),
                        allele_variants.map{|letter| Sequence.complement(letter) },
                        Sequence.revcomp(left), name: name)
  end

  # without name, this fact is used to calculate alignment to a consensus motif word
  def to_s
    left + '[' + allele_variants.join('/') + ']' + right
  end

  def number_of_variants
    allele_variants.size
  end

  def variant(index)
    left + allele_variants[index] + right
  end
end
