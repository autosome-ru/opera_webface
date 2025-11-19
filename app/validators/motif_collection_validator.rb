class MotifCollectionValidator < ActiveModel::Validations::InclusionValidator
  VARIANTS = [
    :hocomoco_14_core, :hocomoco_14_rsnp, :hocomoco_14_rsnp_hq,
  ]
  def delimiter
    VARIANTS
  end
end
