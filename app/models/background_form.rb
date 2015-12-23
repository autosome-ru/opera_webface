require 'active_model'
require 'enumerize'
require_relative 'frequencies_form'

class BackgroundForm
  include ActiveModel::Model
  attr_reader :frequencies, :gc_content, :mode
  extend Enumerize
  enumerize :mode, in: [:wordwise, :gc_content, :frequencies]

  def to_hash
    result = {mode: mode}
    case mode
    when :wordwise
      # do nothing
    when :gc_content
      result.merge!(gc_content: gc_content)
    when :frequencies
      result.merge!(frequencies: frequencies.frequencies)
    end
    result.merge(background: background)
  end

  def frequencies_attributes=(value)
    case value
    when FrequenciesForm
      @frequencies = value
    when Array
      @frequencies = FrequenciesForm.new.tap{|obj| obj.frequencies = value }
    when Hash
      @frequencies = FrequenciesForm.new(value)
    else
      raise "Can't convert #{value} to Frequencies"
    end
  end

  def gc_content=(value)
    @gc_content = value.to_f
  end

  def mode=(value)
    @mode = value.to_sym
  end

  def background
    case mode
    when :wordwise
      Bioinform::Background.wordwise
    when :gc_content
      Bioinform::Background.from_gc_content(gc_content)
    when :frequencies
      frequencies.frequencies
    else
      raise 'Unknown mode'
    end
  end

  validate do |record|
    case record.mode
    when :gc_content
      record.errors.add(:gc_content, 'Must be in 0 to 1')  unless (0..1).include?(record.gc_content)
    when :frequencies
      record.errors.add(:frequencies)  unless frequencies.valid?
    end
  end
end
