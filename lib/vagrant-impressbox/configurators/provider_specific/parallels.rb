module Impressbox
  module Configurators
    module ProviderSpecific
      # Parallels configurator
      class Parallels < Impressbox::Abstract::ConfiguratorProviderSpecific
        # Configure basic settings
        #
        #@param vagrant_config  [Object]  Current vagrant config
        #@param vmname          [String]  Virtual machine name
        #@param cpus            [Integer] CPU count
        #@param memory          [Integer] Memory count
        #@param gui             [Boolean] Use GUI?
        def basic_configure(vagrant_config, vmname, cpus, memory, _gui)
          vagrant_config.vm.provider :parallels do |v|
            v.update_guest_tools = true
            v.customize ["set", :id, "--longer-battery-life", "off"]
            v.memory = memory
            v.cpus = cpus
          end
        end
      end
    end
  end
end
