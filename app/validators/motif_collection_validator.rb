class MotifCollectionValidator < ActiveModel::Validations::InclusionValidator
  VARIANTS = [:hocomoco_10_human, :hocomoco_10_mouse, :hocomoco, :jaspar, :selex, :swissregulon, :homer]
  def delimiter
    VARIANTS
  end
end
