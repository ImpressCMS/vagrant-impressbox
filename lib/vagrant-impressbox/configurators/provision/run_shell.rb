module Impressbox
  module Configurators
    module Primary
      # Configures provision script
      class RunShell < Impressbox::Configurators::AbstractProvision
        def description
          I18n.t 'configuring.provision'
        end

        def can_be_configured?(machine, config_file)
          p = file_config.provision
          false unless p.is_a?(String)
          p.strip!
          !p.empty?
        end

        def configure(machine, config_file)
          instance = create_instance(machine, config_file)
          instance.provision
        end

        def create_instance(machine, config)
          require 'vagrant/plugins/provisioners/shell/provisioner'
          VagrantPlugins::Shell::Provisioner machine, config
        end
      end
    end
  end
end
