class MotifCollectionValidator < ActiveModel::Validations::InclusionValidator
  VARIANTS = [
    :hocomoco_12_core, :hocomoco_12_rsnp, :hocomoco_12_invivo, :hocomoco_12_invitro,
    :hocomoco_11_human, :hocomoco_11_mouse, :jaspar, :selex, :swissregulon, :homer
  ]
  def delimiter
    VARIANTS
  end
end
