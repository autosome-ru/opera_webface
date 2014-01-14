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
        add_task_param(param_name.to_sym)
        extend Enumerize
        add_task_param("#{param_name}_mode".to_sym)
        enumerize "#{param_name}_mode".to_sym, in: [:wordwise, :gc_content, :frequencies]
        add_task_param("#{param_name}_frequencies".to_sym)
        add_task_param("#{param_name}_gc_content".to_sym, &:to_f)

        self.virtual_task_param_names += %w[a c g t].map{|letter| "#{param_name}_#{letter}" }
        %w[a c g t].each_with_index do |letter, index|
          define_method "#{param_name}_#{letter}" do
            instance_variable_set("@#{param_name}_frequencies", [])  unless instance_variable_get("@#{param_name}_frequencies")
            instance_variable_get("@#{param_name}_frequencies")[index]
          end
          define_method "#{param_name}_#{letter}=" do |value|
            instance_variable_set("@#{param_name}_frequencies", [])  unless instance_variable_get("@#{param_name}_frequencies")
            instance_variable_get("@#{param_name}_frequencies")[index] = value.to_f
          end
        end

        define_method "#{param_name}" do
          case instance_variable_get("@#{param_name}_mode").to_sym
          when :wordwise
            [1,1,1,1]
          when :gc_content
            gc_content = instance_variable_get("@#{param_name}_gc_content")
            [(1 - gc_content) / 2.0, gc_content / 2.0, gc_content / 2.0, (1 - gc_content) / 2.0]
          when :frequencies
            instance_variable_get("@#{param_name}_frequencies")
          else
            raise 'Unknown background mode'
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

  def self.task_type
    name
  end

  def attribute_data(attribute)
    #errors[attribute] ? {error: errors[attribute].join('; ')} : {}
    result = {}
    result[:error] = errors[attribute].join('; ')  if errors[attribute] && !errors[attribute].blank?
    result[:parameter_description] = I18n.t("task_parameters.#{task_type}.#{attribute}", default: '')
    result
  end

  def task_description
    I18n.t "task_descriptions.#{task_type}"
  end

  def task_type
    self.class.task_type
  end
end
