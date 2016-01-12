class PvalueBoundarySelectorInput < SimpleForm::Inputs::CollectionSelectInput
  VARIANTS = [:lower, :upper]
  def collection
    @collection ||= begin
      VARIANTS.map{|collection|
        [I18n.t(collection, scope: 'enumerize.pvalue_boundary'), collection]
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
