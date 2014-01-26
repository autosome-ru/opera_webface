require 'active_support/core_ext/object/try'

def in_dir(dir, &block)
  raise 'You should specify block for in_dir'  unless block_given?
  current_dir = Dir.pwd
  begin
    Dir.chdir(dir)
    yield
  rescue
    raise
  ensure
    Dir.chdir(current_dir)
  end
end
