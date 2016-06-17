module Impressbox
  module Configurators
    module Primary
      # Configures network
      class ConfigureNetwork < Impressbox::Configurators::AbstractPrimary

        # Returns description
        #
        #@return [String]
        def description
          I18n.t 'configuring.network'
        end

        def can_be_configured?(_vagrant_config, file_config)
          !file_config.ip.nil? && file_config.ip
        end

        # Do configuration tasks
        #
        #@param vagrant_config  [Object]                            Current vagrant config
        #@param config_file     [::Impressbox::Objects::ConfigFile] Loaded config file data
        def configure(vagrant_config, config_file)
          vagrant_config.vm.network 'private_network',
                                    ip: config_file.ip
        end
      end
    end
  end
end
