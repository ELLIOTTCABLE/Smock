require_relative 'speck_helper'

require 'speck'
Smock::Battery = Speck::Battery.new

Smock::Battery << Speck.new(Smock) do
  
  Speck.new Smock.instance_method :mock! do
    Speck.new do
      smock = Smock.new
      smock.check {|s| s.respond_to? :mock! }
    end
    Speck.new do
      not Smock.new.tap{|s| s.mock! }.check {|s| s.respond_to? :mock! }
      not Smock.new.tap{|s| s.mock! }.check {|s| s.respond_to? :method_missing }
    end
    Speck.new do
      smock = Smock.new
      not smock.check {|s| s.respond_to? :foo }
      not ->{ smock.foo }.check_exception
    end
    Speck.new do
      smock = Smock.new
      smock.bar(1, 2, 3)
      smock.mock!
      smock.check {|s| s.respond_to? :bar }
      not ->{ smock.bar(1, 2, 3) }.check_exception
      ->{ smock.bar(4, 5, 6) }.check_exception(Smock::Exception::UnexpectedArguments)
      smock.methods.check {|m| m.include? :bar }
    end
    Speck.new do
      smock = Smock.new
      argument = Object.new
      return_value = Object.new
      # TODO: This really isn’t sexy, and isn’t semantic. Really, the definition
      #       of #gaz should be a part of the check definition, because it is
      #       important to the construction of the checkee. Perhaps we can
      #       leverage `Object#tap` here?
      smock.gaz(argument) {return_value}
      smock.mock!
      
      smock.gaz(argument).check {|rv| rv == return_value }
    end
  end
  
end
