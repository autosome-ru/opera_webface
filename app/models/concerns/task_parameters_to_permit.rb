module TaskParametersToPermit
  extend ActiveSupport::Concern
    module ClassMethods
    # params to be loaded from the form
    def permitted_params_list
      @permitted_params_list ||= []
    end

    def add_task_permitted_param(param_name, &block)
      case param_name
      when String, Symbol
        permitted_params_list << param_name
        class_eval do
          attr_reader param_name
          if block_given?
            define_method "#{param_name}=" do |value|
              instance_variable_set("@#{param_name}", block.call(value))
            end
          else
            attr_writer param_name
          end
        end
      when Hash
        permitted_params_list << param_name
        # do nothing
      else
        raise 'Unknown permitted parameter type'
      end
    end
  end
end
