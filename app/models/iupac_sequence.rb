### IUPAC alphabet:
# A, C, G, T - nucleotides
# R   -   A/G   -   T C   -   Y
# Y   -   C/T   -   G A   -   R
# S   -   G/C   -   C G   -   S
# W   -   A/T   -   T A   -   W
# K   -   G/T   -   C A   -   M
# M   -   A/C   -   T G   -   K
# B   -   C/G/T   -   G C A   -   V
# D   -   A/G/T   -   T C A   -   H
# H   -   A/C/T   -   T G A   -   D
# V   -   A/C/G   -   T G C   -   B
# N   -   A/C/G/T   -   T/G/C/A   -   N
class IupacSequence
  SEQUENCE_PATTERN = /\A[ACGTRYKMSWBDHVN]+\z/i
  attr_reader :sequence
  
  def initialize(sequence)
    raise ArgumentError, 'Sequence is in wrong format (probably has wrong letters or spaces)'  unless IupacSequence.valid_sequence?(sequence)
    @sequence = sequence
  end
 

  def length
    sequence.length
  end

  def revcomp
    IupacSequence.revcomp(sequence)
  end

  def self.complement(sequence)
  # A - T; C - G; G - C; T - A; N - N
  # R   -   A/G   -   T/C   -   Y
  # Y   -   C/T   -   G/A   -   R
  # S   -   G/C   -   C/G   -   S
  # W   -   A/T   -   T/A   -   W
  # K   -   G/T   -   C/A   -   M
  # M   -   A/C   -   T/G   -   K
  # B   -   C/G/T   -   G/C/A   -   V
  # D   -   A/G/T   -   T/C/A   -   H
  # H   -   A/C/T   -   T/G/A   -   D
  # V   -   A/C/G   -   T/G/C   -   B
    sequence.tr('ACGTRYSWKMBDHVNacgtryswkmbdhvn', 'TGCAYRSWMKVHDBNtgcayrswmkvhdbn')
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
