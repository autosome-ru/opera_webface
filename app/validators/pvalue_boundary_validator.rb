class PvalueBoundaryValidator < ActiveModel::Validations::InclusionValidator
  VARIANTS = [:upper, :lower]
  def delimiter
    VARIANTS
  end
end
