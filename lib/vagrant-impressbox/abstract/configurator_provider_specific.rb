# Impressbox namespace
module Impressbox
  module Abstract
    # Base configurator
    class ConfiguratorProviderSpecific
      # @!attribute [rw] config
      attr_accessor :config

      # Is with same name like current provider?
      #
      #@param name  [Symbol]  Current provider name
      #
      #@return [Boolean]
      def same?(name)
        self.class.name.eql?(name)
      end

      # Configure specific
      #
      #@param vagrant_config  [Object]                            Current vagrant config
      #@param cfg             [::Impressbox::Objects::ConfigFile] Loaded config file data
      def specific_configure(vagrant_config, cfg)
      end

      # Configure basic settings
      #
      #@param vagrant_config  [Object]  Current vagrant config
      #@param vmname          [String]  Virtual machine name
      #@param cpus            [Integer] CPU count
      #@param memory          [Integer] Memory count
      #@param gui             [Boolean] Use GUI?
      def basic_configure(vagrant_config, vmname, cpus, memory, gui)
      end
    end
  end
end
