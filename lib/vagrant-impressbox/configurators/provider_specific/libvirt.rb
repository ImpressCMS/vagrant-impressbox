module Impressbox
  module Configurators
    module ProviderSpecific
      # Libvirt configurator
      class Libvirt < Impressbox::Abstract::ConfiguratorProviderSpecific
        # Configure basic settings
        #
        #@param vagrant_config  [Object]  Current vagrant config
        #@param vmname          [String]  Virtual machine name
        #@param cpus            [Integer] CPU count
        #@param memory          [Integer] Memory count
        #@param gui             [Boolean] Use GUI?
        def basic_configure(vagrant_config, vmname, cpus, memory, gui)
          vagrant_config.vm.provider :libvirt do |v|
            v.memory = memory
            v.cpus = cpus
            v.nested = false
            v.cpu_mode = 'host-model'
            v.graphics_type = if gui then
                                'sdl'
                              else
                                'none'
                              end
          end
        end
      end
    end
  end
end
