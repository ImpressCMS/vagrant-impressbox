require_relative 'base'

module Impressbox::Configurators::ProviderSpecific
    # Virtualbox configurator
    class VirtualBox < Impressbox::Configurators::Base::ProviderSpecific
      # Configure basic settings
      def basic_configure(vmname, cpus, memory, gui)
        @config.vm.provider 'virtualbox' do |v|
          v.gui = gui
          v.vmname = vmname
          v.cpus = cpus
          v.memory = memory
        end
      end
  end
end
