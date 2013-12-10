class Module
  #synchronize method on mutex (mutex_meth - getter for a mutex)
  def synchronize_methods(mutex_meth, *methods)
    methods.each do |meth|
      meth_old = instance_method(meth)
      define_method meth do |*args,&block|
        send(mutex_meth).synchronize { meth_old.bind(self).call(*args,&block) }
      end
    end
  end
  
  # create attr_readers for mutices with lazy initialization
  def create_mutex(*mutices)
    mutices.each do |mutex|
      define_method mutex do
        instance_variable_get("@#{mutex}") || instance_variable_set("@#{mutex}",Mutex.new)
      end
    end
  end
end
  
=begin

# This is an example of object. Both readers can be runned simultaneous; But no one can be runned with writer
  def reader_1
    @rw_mutex.synchronize {
      @w_mutex.lock
    }
      @x
    ensure
      @w_mutex.unlock
  end
  def reader_2
    @rw_mutex.synchronize {
      @w_mutex.lock
    }
      @y
    ensure
      @w_mutex.unlock
  end
  
  def writer
    @rw_mutex.synchronize{
      @w_mutex.synchronize {
        @x.next!
        @y.next!
      }
    }
  end
=end

# class X
#   create_mutex :rw_mut,:w_mut
#   def initialize; @x, @y= 'a', 'a'
#   def reader_1; @x; end
#   def reader_2; @y; end
#   def writer_1; @x.next!;end
#   def writer_2; @y.next!;end
#   def writer_3; @x.next!; @y.next!; end
# synchronize_methods_rw :rw_mut, :w_lock, readers: [:reader_1,:reader_2], writers: [:writer_1,:writer_2,:writer_3]
#end 

=begin
 Need Testing
 And I'm not sure we need such a method in OperaHouse it can be slower than usual sync and give us no outcomes
def synchronize_methods_rw(rw_lock,w_lock,options={})
  options[:writers].each{|meth| option[:readers].delete(meth.to_s); option[:readers].delete(meth.to_sym)}
  options[:readers].each do |meth|
    meth_old = instance_method(meth)
    define_method meth do |*args,&block|
      begin
        send(rw_lock).synchronize { send(w_lock).lock }
        meth_old.bind(self).call(*args,&block)
      ensure
        send(w_lock).unlock
      end
    end
  end
  
  options[:writers].each do |meth|
    meth_old = instance_method(meth)
    define_method meth do |*args,&block|        
      send(rw_lock).synchronize { 
        send(w_lock).synchronize{
          meth_old.bind(self).call(*args,&block)
        }
      }
    end
  end
end
 
=end