module Macroape::ComparesHelper
  def pwm_from_file(filename, ticket)
    Bioinform::MotifModel::PWM.from_string(SMBSMCore.get_content(ticket, filename))
  end
end
