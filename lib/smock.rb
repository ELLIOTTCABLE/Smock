##
# Simple, oopy mocks.
class Smock
  Version = 0
  
  def initialize
    @stubs = Hash.new
  end
  
  ##
  # This method activates a `Smock`, causing it to stop accepting new stubs
  # and start responding to stubs. It essentially flips the `Smock`’s state
  # from creation to usage.
  def mock!
    singleton = class<<self;self;end
    Smock.ancestors.inject(Smock.instance_methods) {|methods, ancestor|
      methods -= ancestor.instance_methods unless ancestor == Smock; methods }
      .each do |imeth|
        singleton.send :undef_method, imeth
      end
    
    @stubs.each do |nnethod, stubs|
      singleton.send :define_method, nnethod do |*args|
        raise Exception::UnexpectedArguments unless stubs.has_key? args
        stubs[args] ? stubs[args].call : nil
      end
    end
    self.send :remove_instance_variable, :@stubs
    return self
  end
  
  ##
  # Any method called on an inactiave `Smock` will become a method on the
  # `Smock` once it is activated. Arguments to to the method will become sets
  # of expected arguments; if a block is given, the return value of the block
  # will become the return value of the method when that particular set of
  # arguments is passed.
  # 
  # The same method may be defined in this way multiple times with different
  # sets of arguments; the callable method will later accept any particular
  # set of arguments that it had previously been passed (returning the return
  # value of the block passed when those arguments were defined, if any).
  def method_missing nnethod, *arguments
    @stubs[nnethod] ||= Hash.new
    @stubs[nnethod][arguments] = block_given? ? Proc.new : nil
    return self
  end
  
  class Exception < Speck::Exception
    ##
    # Raised when an active smock receives a method call with unexpected
    # arguments
    UnexpectedArguments = Class.new(self)
  end
  
end
