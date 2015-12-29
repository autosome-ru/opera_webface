require 'virtus'
require 'bioinform'

class BackgroundForm
  include ActiveModel::Model
  include Virtus.model(nullify_blank: true)
  attribute :mode, Symbol, default: :wordwise
  attribute :gc_content, Float
  attribute :frequencies, FrequenciesForm

  MODE_VARIANTS = [:wordwise, :gc_content, :frequencies]
  validates :mode,  inclusion: {in: MODE_VARIANTS, message: 'Unknown background mode `%{value}`'}
  validate do |record|
    case record.mode
    when :gc_content
      record.errors.add(:gc_content, 'Must be in 0 to 1')  unless (0..1).include?(record.gc_content)
    when :frequencies
      record.errors.add(:frequencies)  unless frequencies.valid?
    end
  end

  def frequencies_attributes=(value)
    case value
    when Hash
      self.frequencies = value
    when Array
      self.frequencies = [:a,:c,:g,:t].zip(value).inject({}){|res, (letter, frequency)| res.merge(letter => frequency) }
    end
  end

  def background
    case mode
    when :wordwise
      Bioinform::Background.wordwise
    when :gc_content
      Bioinform::Background.from_gc_content(gc_content)
    when :frequencies
      frequencies.background
    else
      raise 'Unknown mode'
    end
  end

  def self.uniform
    BackgroundForm.new(mode: :wordwise, gc_content: 0.5, frequencies: FrequenciesForm.uniform)
  end
end
