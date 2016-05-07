class ChipmunkResultsDecorator < Draper::Decorator
  delegate_all

  def pcm
    helpers.format_matrix_as_table(object.pcm.matrix, arity: object.arity, round: 3)
  end

  def pwm
    helpers.format_matrix_as_table(object.pwm.matrix, arity: object.arity, round: 3)
  end

  def ppm
    helpers.format_matrix_as_table(object.ppm.matrix, arity: object.arity, round: 3)
  end

  # Define presentation-specific methods here. Helpers are accessed through
  # `helpers` (aka `h`). You can override attributes, for example:
  #
  #   def created_at
  #     helpers.content_tag :span, class: 'time' do
  #       object.created_at.strftime("%a %m/%d/%y")
  #     end
  #   end

end
