module Impressbox
  module Configurators
    module Action
      module MachineUp
        #Updates hosts
        class HostsUpdater < Impressbox::Configurators::AbstractAction

          # This method is used to configure/run configurator
          def configure(app, env, config_file, machine)
            require 'vagrant-hostmanager/provisioner'
            instance = VagrantPlugins::HostManager::HostsFile::Updater.new(machine.env, machine.provider_name)
            instance.update_guest machine
            instance.update_host
          end

          # This method is used for description
          def description
            I18n.t('configuring.hosts')
          end

        end
      end
    end
  end
end
