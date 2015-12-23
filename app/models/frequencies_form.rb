require 'active_model'

class FrequenciesForm
  include ActiveModel::Model
  attr_accessor :a,:c,:g,:t
  def frequencies
    Bioinform::Background.from_frequencies(* [a, c, g, t].map(&:to_f))
  end
  def frequencies=(value)
    @a, @c, @g, @t = *value
  end
  validate do |record|
    record.errors.add(:base, 'Must give 1 being summed')  unless (record.frequencies.inject(0.0, &:+) - 1.0).abs < 0.001
  end
end
