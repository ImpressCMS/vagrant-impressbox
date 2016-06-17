module Impressbox
  module Configurators
    module Primary
      # Configures provision script
      class RunShell < Impressbox::Configurators::AbstractProvision

        # Returns description
        #
        #@return [String]
        def description
          I18n.t 'configuring.provision'
        end

        # Can be executed ?
        #
        #@param machine     [::Vagrant::Machine]                Current machine
        #@param config_file [::Impressbox::Objects::ConfigFile] Loaded config file data
        #
        #@return            [Boolean]
        def can_be_configured?(machine, config_file)
          p = file_config.provision
          false unless p.is_a?(String)
          p.strip!
          !p.empty?
        end

        # Configure machine on provision
        #
        #@param machine         [::Vagrant::Machine]                Current machine
        #@param config_file     [::Impressbox::Objects::ConfigFile] Loaded config file data
        def configure(machine, config_file)
          instance = create_instance(machine, config_file)
          instance.provision
        end

        # Creates shell provisioner instance
        #
        #@param machine [::Vagrant::Machine]                Current machine
        #@param config  [::Impressbox::Objects::ConfigFile] Loaded config file data
        #
        #@return [::VagrantPlugins::Shell::Provisioner]
        def create_instance(machine, config)
          require 'vagrant/plugins/provisioners/shell/provisioner'
          ::VagrantPlugins::Shell::Provisioner machine, config
        end
      end
    end
  end
end
