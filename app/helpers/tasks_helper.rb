module TasksHelper
  class TaskFormBuilder < SimpleForm::FormBuilder
    def input(attribute_name, options = {}, &block)
      task_type = options[:task_type] || object.class.name.split('::')
      attribute = attribute_name.to_sym
      
      additional_options = {}
      all_errors = []
      all_errors += object.send(attribute).errors.full_messages  if object.send(attribute).respond_to?(:errors)
      all_errors += object.errors.full_messages_for(attribute)  if all_errors.empty?
      additional_options[:error] = all_errors.join(";\n")  unless all_errors.empty?

      defaults = object.class.ancestors.drop(1).select(&:name).map{|klass|
        ['task_parameters', *klass.name.split('::'), attribute].compact.reject(&:empty?).join('.').to_sym
      }
      i18n_path = options[:i18n_description] || ['task_parameters', task_type, attribute].compact.join('.')
      additional_options[:parameter_description] = I18n.t(i18n_path, default: [*defaults, "Description not provided (#{i18n_path})"])
     
      options[:input_html] ||= {}
      options[:input_html][:data] ||= {}
      options[:input_html][:data].merge!(additional_options)

      super(attribute_name, options, &block)
    end
  end

  def task_form_for(object, *args, &block)
    options = args.extract_options!
    simple_form_for(object, *(args << options.merge(builder: TaskFormBuilder)), &block)
  end

  def image_tag_if_exists(image_path, options = {})
    if image_path && OperaWebface::Application.assets.find_asset(image_path)
      image_tag image_path, options
    else
      nil
    end
  end
end
