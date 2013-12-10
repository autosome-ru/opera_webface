class Task
  include ActiveModel::Model

  def task_params
    key_value_pairs = self.class.task_param_names.map{|param_name| 
      [param_name, send(param_name)]
    }
    Hash[key_value_pairs]
  end

  class << self
    attr_accessor :task_param_names
    def add_task_params(*params, &block)
      @task_param_names ||= []
      @task_param_names += params
      class_eval do
        params.each do |param_name|
          define_method param_name do
            instance_variable_get "@#{param_name}"
          end
          define_method "#{param_name}=" do |value|
            instance_variable_set("@#{param_name}", block ? block.call(value) : value)
          end
        end
      end
    end
  end

  def task_type
    self.class.name
  end
end
