require 'active_model'
require_relative 'concerns/task_parameters_to_permit'
require_relative 'concerns/submission_parameters'
require_relative 'concerns/background_parameters'
require_relative 'concerns/data_model_parameters'

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

  def task_description
    I18n.t "task_descriptions.#{task_type}"
  end

  def task_type
    self.class.task_type
  end
end
