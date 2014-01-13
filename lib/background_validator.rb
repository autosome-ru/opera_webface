class BackgroundValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    unless (value == [1,1,1,1]) || (value.inject(&:+) - 1.0).abs < 0.001
      message = options[:message] || "sum should be 1"
      record.errors[attribute] << message
    end
  end
end
