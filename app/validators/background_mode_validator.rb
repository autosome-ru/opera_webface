class BackgroundModeValidator < ActiveModel::Validations::InclusionValidator
  VARIANTS = [:wordwise, :gc_content, :frequencies]
  def delimiter
    VARIANTS
  end
end
