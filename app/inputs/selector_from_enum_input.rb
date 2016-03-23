# Usage:
#   class BackgroundModeSelectorInput < SelectorFromEnumInput
#     variants [:wordwise, :gc_content, :frequencies]
#     i18n_scope 'enumerize.background.mode'
#   end
#
class SelectorFromEnumInput < SimpleForm::Inputs::CollectionSelectInput
  def self.variants(value)
    define_method(:variants) { value }
  end

  def self.i18n_scope(value)
    define_method(:i18n_scope) { value }
  end

  def i18n_scope
    raise NotImplementedError, 'Define in a subclass'
  end

  def variants
    raise NotImplementedError, 'Define in a subclass'
  end

  # Can be redefined in a subclass
  def skip_include_blank?
    true
  end

  def collection
    @collection ||= begin
      variants.map{|item|
        [I18n.t(item, scope: i18n_scope), item]
      }
    end
  end


  def detect_collection_methods
    [:first, :second]
  end
end
