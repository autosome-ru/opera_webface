class MotifTypeSelectorInput < SimpleForm::Inputs::CollectionSelectInput
  VARIANTS = [:PWM, :PCM, :PPM]
  def collection
    @collection ||= begin
      VARIANTS.map{|collection|
        [I18n.t(collection, scope: 'enumerize.motif_type'), collection]
      }
    end
  end

  def skip_include_blank?
    true
  end

  def detect_collection_methods
    [:first, :second]
  end
end
