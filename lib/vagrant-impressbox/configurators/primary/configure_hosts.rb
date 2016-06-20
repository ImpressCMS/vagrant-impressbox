module Impressbox
  module Configurators
    module Primary
      # Configures hostnames (with HostManager plug-in)
      class ConfigureHosts < Impressbox::Abstract::ConfiguratorPrimary

        # Returns description
        #
        #@return [String]
        def description
          I18n.t 'configuring.hosts'
        end

        # Do configuration tasks
        #
        #@param vagrant_config  [Object]                            Current vagrant config
        #@param config_file     [::Impressbox::Objects::ConfigFile] Loaded config file data
        def configure(vagrant_config, config_file)
          require 'vagrant-hostmanager'

          hostname, aliases = extract_data(config_file)

          vagrant_config.vm.hostname = hostname
          configure_hostmanager vagrant_config.hostmanager, aliases
        end

        private

        # Does HostManager configuration
        #
        #@param hostmanager [Object] Part of current vagrant config for configuring HostManager
        #@param aliases     [Array]  Aliases for hostname
        def configure_hostmanager(hostmanager, aliases)
          hostmanager.enabled = true
          hostmanager.manage_host = true
          hostmanager.manage_guest = true
          hostmanager.ignore_private_ip = false
          hostmanager.include_offline = false
          hostmanager.aliases = aliases unless aliases.empty?
        end

        # Extracts hostname and aliases array from loaded config file
        #
        #@param cfg [::Impressbox::Objects::ConfigFile] Loaded config file data
        #
        #@return [Array]
        def extract_data(cfg)
          aliases = cfg.hostname.dup
          if aliases.is_a?(Array)
            hostname = aliases.shift
          else
            hostname = aliases.dup
            aliases = []
          end
          [hostname, aliases]
        end
      end
    end
  end
end
