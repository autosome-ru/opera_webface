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
        param_name = param_name.to_sym
        task_param_names << param_name
        virtual_task_param_names << {"_bg_#{param_name}_attributes".to_sym => [:mode, :gc_content, :frequencies_attributes => [:a,:c,:g,:t]]}

        define_method "#{param_name}" do
          instance_variable_get("@_bg_#{param_name}").background
        end

        define_method "_bg_#{param_name}" do
          instance_variable_get("@_bg_#{param_name}")
        end

        define_method "_bg_#{param_name}_attributes=" do |value|
          instance_variable_set("@_bg_#{param_name}", Background.new(value))
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
