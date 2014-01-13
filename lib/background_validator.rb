class BackgroundValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    unless (value == [1,1,1,1]) || (value.inject(&:+) - 1.0).abs < 0.001
      record.errors[attribute] << "sum should be 1"
    end
    unless value.all?{|el| (0..1).include? el}
      record.errors[attribute] << "frequencies should be in range 0..1"
    end
  end
end
