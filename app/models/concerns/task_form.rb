module TaskForm
  extend ActiveSupport::Concern

  module ClassMethods
    def task_type
      name
    end

    # def permitted_params_list
    #   attributes.map{|attr|
    #     attr.respond_to?(permitted_params) 
    #   }
    # end
  end

  def task_type
    self.class.task_type
  end

  def task_description
    I18n.t "task_descriptions.#{task_type}"
  end
end
