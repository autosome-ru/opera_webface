class Task
  include ActiveModel::Model

  def task_params
    key_value_pairs = self.class.task_param_names.map{|param_name| 
      [param_name, send(param_name)]
    }
    Hash[key_value_pairs]
  end

  class << self
    attr_writer :task_param_names, :virtual_task_param_names
    def task_param_names
      @task_param_names ||= []
    end
    
    def virtual_task_param_names
      @virtual_task_param_names ||= []
    end

    def add_task_param(param_name, &block)
      task_param_names.push(param_name)
      class_eval do
        attr_reader param_name
        define_method "#{param_name}=" do |value|
          instance_variable_set("@#{param_name}", block ? block.call(value) : value)
        end
      end
    end
    
    def add_background_task_param(param_name)
      class_eval do
        add_task_param(param_name)
        self.virtual_task_param_names += %w[a c g t].map{|letter| "#{param_name}_#{letter}" }
        %w[a c g t].each_with_index do |letter, index|
          define_method "#{param_name}_#{letter}" do
            instance_variable_set("@#{param_name}", [1,1,1,1])  unless instance_variable_get("@#{param_name}")
            instance_variable_get("@#{param_name}")[index]
          end
          define_method "#{param_name}_#{letter}=" do |value|
            instance_variable_set("@#{param_name}", [1,1,1,1])  unless instance_variable_get("@#{param_name}")
            instance_variable_get("@#{param_name}")[index] = value.to_f
          end
        end
      end
    end

    def add_task_params(*params, &block)
      params.each do |param_name|
        add_task_param(param_name, &block)
      end
    end

    def add_background_task_params(*params)
      params.each do |param_name|
        add_background_task_param(param_name)
      end
    end 
  end

  def task_type
    self.class.name
  end
end
