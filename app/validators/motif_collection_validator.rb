class MotifCollectionValidator < ActiveModel::Validations::InclusionValidator
  VARIANTS = [
    :hocomoco_13_core, :hocomoco_13_rsnp, :hocomoco_13_rsnp_hq, :hocomoco_13_invivo, :hocomoco_13_invitro,
    :hocomoco_12_core, :hocomoco_12_rsnp, :hocomoco_12_rsnp_hq, :hocomoco_12_invivo, :hocomoco_12_invitro,
    :hocomoco_11_human, :hocomoco_11_mouse, :jaspar, :selex, :swissregulon, :homer
  ]
  def delimiter
    VARIANTS
  end
end
