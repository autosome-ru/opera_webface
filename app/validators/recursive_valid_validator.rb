class RecursiveValidValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    unless value.valid?
      if value.respond_to?(:errors)
        error_details = value.errors.full_messages.join('; ')
        msg = "is invalid (#{error_details})"
      else
        msg = "is invalid"
      end
      record.errors.add(attribute, msg)
    end
  end
end
