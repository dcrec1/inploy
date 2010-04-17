module Inploy
  module Initializable
    attr_accessor :initializers

    def initializer(name, &block)
      raise ArgumentError, "A block must be passed when defining an initializer" unless(block)
      @initializers ||= []
      @initializers << block
    end
  end
end
