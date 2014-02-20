module TasksHelper
  class TaskFormBuilder < SimpleForm::FormBuilder
    def input(attribute_name, options = {}, &block)
      task_type = options[:task_type] || object.class.name.split('::')
      attribute = attribute_name.to_sym
      result = {}
      all_errors = []
      all_errors += object.send(attribute).errors.full_messages  if object.send(attribute).respond_to?(:errors)
      all_errors += object.errors.full_messages_for(attribute)  if all_errors.empty?
      result[:error] = all_errors.join(";\n")  unless all_errors.empty?

      i18n_path = ['task_parameters', task_type, attribute].compact.join('.')
      result[:parameter_description] = I18n.t(i18n_path, default: "Description not provided (#{i18n_path})")
      options[:input_html] ||= {}
      options[:input_html][:data]||={}
      options[:input_html][:data].merge!(result)

      super(attribute_name, options, &block)
    end
  end

  def task_form_for(object, *args, &block)
    options = args.extract_options!
    simple_form_for(object, *(args << options.merge(builder: TaskFormBuilder)), &block)
  end
end
