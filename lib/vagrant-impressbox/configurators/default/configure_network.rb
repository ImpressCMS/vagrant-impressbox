module Impressbox
  module Configurators
    module Default
      # Configures network
      class ConfigureNetwork < Impressbox::Configurators::Default
        def description
          I18n.t 'configuring.network'
        end

        def can_be_configured?(_vagrant_config, file_config)
          !file_config.ip.nil? && file_config.ip
        end

        def configure(vagrant_config, config_file)
          vagrant_config.vm.network 'private_network',
                                    ip: config_file.ip
        end
      end
    end
  end
end
