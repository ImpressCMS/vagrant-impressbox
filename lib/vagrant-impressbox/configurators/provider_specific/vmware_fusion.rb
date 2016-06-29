module Impressbox
  module Configurators
    module ProviderSpecific
      # Parallels configurator
      class VmwareFusion < Impressbox::Abstract::ConfiguratorProviderSpecific
        # Configure basic settings
        #
        #@param vagrant_config  [Object]  Current vagrant config
        #@param vmname          [String]  Virtual machine name
        #@param cpus            [Integer] CPU count
        #@param memory          [Integer] Memory count
        #@param gui             [Boolean] Use GUI?
        def basic_configure(vagrant_config, vmname, cpus, memory, gui)
          vagrant_config.vm.provider :vmware_fusion do |v|
            v.gui = gui
            v.vmx["memsize"] = memory.to_s
            v.vmx["numvcpus"] = cpus.to_s
            v.vmx['displayname'] = vmname
          end
        end
      end
    end
  end
end
