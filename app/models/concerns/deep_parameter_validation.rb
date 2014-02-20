require 'active_support/concern'

module DeepParameterValidation
  extend ActiveSupport::Concern
  module ClassMethods

    def add_deep_validation_for(param_name)
      validate do |record|
        value = record.send(param_name)
        unless value.valid?
          errors = value.errors[:base]
          errors << 'is invalid' if errors.empty?
          record.errors.add(param_name, errors.join(";\n"))
        end
      end
    end

  end
end
