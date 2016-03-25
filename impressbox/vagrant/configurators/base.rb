module Impressbox
  module Vagrant
    module Configurators
      # Base configurator
      class Base
        # Config variable
        @config = nil

        # initializer
        def initialize(config)
          @config = config
        end

        # Is with same name?
        def same?(name)
          self.class.name.eql?(name)
        end
      end
    end
  end
end
