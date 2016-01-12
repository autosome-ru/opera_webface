class NucleotideFrequenciesInput < SimpleForm::Inputs::Base
  disable :label
  def input(wrapper_options = nil)
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
