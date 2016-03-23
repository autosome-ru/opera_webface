class NucleotideFrequenciesInput < SimpleForm::Inputs::Base
  disable :label
  def input(wrapper_options = nil)
    input_html_classes.unshift("numeric")
    if html5?
      input_html_options[:type] ||= "number"
      input_html_options[:min] ||= 0.0
      input_html_options[:max] ||= 1.0
      input_html_options[:step] ||= 0.01
    end
    merged_input_options = merge_wrapper_options(input_html_options, wrapper_options.merge(wrapper: false))

    @builder.fields_for(attribute_name, object.send(attribute_name)) do |f|
        [:a, :c, :g, :t].map do |letter|
          template.content_tag(:div, class: 'frequency') do
            template.concat  f.label(letter, "#{letter.upcase}:")
            template.concat  f.text_field(letter, merged_input_options)
          end
        end.inject(&:safe_concat)
    end
  end
end
