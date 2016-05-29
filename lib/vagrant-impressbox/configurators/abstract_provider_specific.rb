# Impressbox namespace
module Impressbox
  module Configurators
      # Base configurator
      class AbstractProviderSpecific
        # @!attribute [rw] config
        attr_accessor :config

        # initializer
        def initialize(config)
          @config = config
        end

        # Is with same name?
        def same?(name)
          self.class.name.eql?(name)
        end

        # Configure specific
        def specific_configure(cfg)
        end

        # Configure basic settings
        def basic_configure(vmname, cpus, memory, gui)
        end
      end
  end
end
