require 'active_support/concern'
require_relative 'deep_parameter_validation'

module BackgroundParameters
  extend ActiveSupport::Concern
  include DeepParameterValidation

  module ClassMethods
    def add_background_task_param(param_name)
      param_name = param_name.to_sym
      add_task_submission_param(param_name){|task, background_value| background_value.value.to_s }
      add_task_permitted_param("#{param_name}_attributes" => [:mode, :gc_content, :frequencies_attributes => [:a,:c,:g,:t] ])

      attr_reader param_name

      define_method "#{param_name}_attributes=" do |value|
        instance_variable_set("@#{param_name}", OperaWebface::Background.new(value))
      end
      add_deep_validation_for(param_name)
    end
  end
end
