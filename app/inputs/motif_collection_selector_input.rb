class MotifCollectionSelectorInput < SimpleForm::Inputs::CollectionSelectInput
  VARIANTS = [:hocomoco_10_human, :hocomoco_10_mouse, :hocomoco, :jaspar, :selex, :swissregulon, :homer]
  def collection
    @collection ||= begin
      VARIANTS.map{|collection|
        [I18n.t(collection, scope: 'enumerize.collection'), collection]
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
