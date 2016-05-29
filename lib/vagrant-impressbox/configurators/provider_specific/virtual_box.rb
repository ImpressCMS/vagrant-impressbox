module Impressbox
  module Configurators
    module ProviderSpecific
      # Virtualbox configurator
      class VirtualBox < Impressbox::Configurators::AbstractProviderSpecific
        # Configure basic settings
        def basic_configure(vagrant_config, vmname, cpus, memory, gui)
          vagrant_config.vm.provider 'virtualbox' do |v|
            v.gui = gui
            v.vmname = vmname
            v.cpus = cpus
            v.memory = memory
          end
        end
      end
    end
  end
end
