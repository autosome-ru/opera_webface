class BackgroundModeSelectorInput < SimpleForm::Inputs::CollectionSelectInput
  VARIANTS = [:wordwise, :gc_content, :frequencies]
  def collection
    @collection ||= begin
      VARIANTS.map{|collection|
        [I18n.t(collection, scope: 'enumerize.background.mode'), collection]
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
