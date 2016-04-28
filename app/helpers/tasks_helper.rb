module TasksHelper
  class TaskFormBuilder < SimpleForm::FormBuilder
    def klass_hierarchy(klass)
      klass.ancestors.select(&:name).map{|klass|
        klass.name.split('::').reject(&:empty?)
      }
    end

    def translation_hierarchy(klass, prefix:, suffix:)
      hierarchy = klass_hierarchy(klass).map{|klasses|
        [prefix, klasses, suffix].compact.reject(&:empty?).flatten.join('.')
      }.map(&:to_sym)
      I18n.t(hierarchy.first, default: [*hierarchy.drop(1), "Description not provided (#{hierarchy.first})"])
    end

    private :klass_hierarchy, :translation_hierarchy

    def input(attribute_name, options = {}, &block)
      task_type = options[:task_type] || object.class.name.split('::')
      attribute = attribute_name.to_sym
      
      additional_options = {}
      all_errors = []
      all_errors += object.send(attribute).errors.full_messages  if object.send(attribute).respond_to?(:errors)
      all_errors += object.errors.full_messages_for(attribute)  if all_errors.empty?
      additional_options[:error] = all_errors.join(";\n")  unless all_errors.empty?

      if options[:i18n_description]
        additional_options[:parameter_description] = I18n.t(options[:i18n_description])
      else
        additional_options[:parameter_description] = translation_hierarchy(object.class, prefix: 'task_parameters', suffix: attribute_name)
      end

      if options[:i18n_label]
        options[:label] ||= I18n.t(options[:i18n_label])
      else
        options[:label] ||= translation_hierarchy(object.class, prefix: 'label', suffix: attribute_name)
      end
     
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
