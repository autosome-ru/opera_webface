class OperaSoloist
  def initialize(command); @pout = IO.popen(command); end
  def pid; @pout.pid; end
  def result
    @pout.read
  ensure
    @pout.close_read
  end
end
