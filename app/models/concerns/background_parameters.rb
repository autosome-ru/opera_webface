require 'active_support/concern'

module BackgroundParameters
  extend ActiveSupport::Concern

  module ClassMethods
    def add_background_task_param(param_name)
      class_eval do
        param_name = param_name.to_sym
        add_task_submission_param(param_name){|task, value| value.background }
        add_task_permitted_param("#{param_name}_attributes" => [:mode, :gc_content, :frequencies_attributes => [:a,:c,:g,:t] ])

        attr_reader param_name

        define_method "#{param_name}_attributes=" do |value|
          instance_variable_set("@#{param_name}", Background.new(value))
        end

        validate do |record|
          record.errors.add(param_name)  unless record.send(param_name).valid?
        end
      end
    end
  end
end
