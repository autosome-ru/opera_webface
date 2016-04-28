module TaskForm
  extend ActiveSupport::Concern

  module ClassMethods
    def task_type
      name
    end
  end

  def task_attributes
    attributes
  end

  def task_params
    task_attributes.map{|attr_key, attr_value|
      if attr_value.respond_to?(:task_params)
        val = attr_value.task_params
      elsif attr_value.respond_to?(:attributes)
        val = attr_value.attributes
      else
        val = attr_value
      end
      [attr_key, val]
    }.to_h
  end

  def task_type
    self.class.task_type
  end

  def task_description
    I18n.t "task_descriptions.#{task_type}"
  end
end
