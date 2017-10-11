class MotifCollectionValidator < ActiveModel::Validations::InclusionValidator
  VARIANTS = [:hocomoco_11_human, :hocomoco_11_mouse, :jaspar, :selex, :swissregulon, :homer]
  def delimiter
    VARIANTS
  end
end
