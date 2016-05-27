require_relative File.join('..', 'base', 'default')

module Impressbox::Configurators::Default
    # Configures hostnames (with HostManager plug-in)
    class ConfigureHosts < BaseAction

      def description
        I18n.t 'configuring.hosts'
      end

      def configure(vagrant_config, config_file)
        require 'vagrant-hostmanager'

        hostname, aliases = extract_data(config_file)

        vagrant_config.vm.hostname = hostname
        configure_hostmanager vagrant_config.hostmanager, aliases
      end

      def configure_hostmanager(hostmanager, aliases)
        hostmanager.manage_host = true
        hostmanager.manage_guest = true
        hostmanager.ignore_private_ip = false
        hostmanager.include_offline = true
        hostmanager.aliases = aliases unless aliases.empty?
      end

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
