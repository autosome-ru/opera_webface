require 'virtus'
require 'bioinform'

class FrequenciesForm
  include ActiveModel::Model
  include Virtus.model(nullify_blank: true)
  attribute :a, Float
  attribute :c, Float
  attribute :g, Float
  attribute :t, Float

  def background
    Bioinform::Background.from_frequencies([a, c, g, t])
  end

  validate do |record|
    record.errors.add(:base, 'Frequencies should be positive')  unless [a, c, g, t].all?{|prob| prob >= 0 }
    sum_probabiliies = [a, c, g, t].inject(0.0, &:+)
    record.errors.add(:base, 'Must give 1 being summed')  unless (sum_probabiliies - 1.0).abs < 0.001
  end

  def self.uniform
    FrequenciesForm.new(a: 0.25, c: 0.25, g: 0.25, t: 0.25)
  end
end
