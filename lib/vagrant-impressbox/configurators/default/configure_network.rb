require_relative File.join('..', 'base', 'default')

module Impressbox::Configurators::Default
    # Configures network
    class ConfigureNetwork < BaseAction

      def description
        I18n.t 'configuring.network'
      end

      def can_be_configured?(vagrant_config, file_config)
        !file_config.ip.nil? && file_config.ip
      end

      def configure(vagrant_config, config_file)
        vagrant_config.vm.network 'private_network',
                                  ip: config_file.ip
      end
    end
  end
