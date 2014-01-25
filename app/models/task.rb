class Task
  include ActiveModel::Model
  include TaskParametersToPermit
  include SubmissionParameters
  include BackgroundParameters
  include DataModelParameters

  class << self
    def add_task_param(param_name, &block)
      add_task_submission_param(param_name)
      add_task_permitted_param(param_name, &block)
    end

    def add_task_params(*params, &block)
      params.each do |param_name|
        add_task_param(param_name, &block)
      end
    end
  end

  def self.task_type
    name
  end

  def attribute_data(attribute)
    attribute = attribute.to_sym
    result = {}
    all_errors = []
    all_errors += send(attribute).errors[:base]  if send(attribute).respond_to?(:errors)
    all_errors += errors[attribute]  if all_errors.empty?
    result[:error] = all_errors.join('; ')  unless all_errors.empty?

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
