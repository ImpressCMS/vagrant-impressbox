module Impressbox
  module Configurators
    module Primary
      # Configures default SSH configuration
      class ConfigureSsh < Impressbox::Configurators::AbstractPrimary

        # Returns description
        #
        #@return [String]
        def description
          I18n.t 'configuring.ssh'
        end

        # Do configuration tasks
        #
        #@param vagrant_config  [Object]                            Current vagrant config
        #@param config_file     [::Impressbox::Objects::ConfigFile] Loaded config file data
        def configure(vagrant_config, config_file)
          # @config.ssh.insert_key = true
          vagrant_config.ssh.pty = false
          vagrant_config.ssh.forward_x11 = false
          vagrant_config.ssh.forward_agent = false
          if !config_file.vars.nil? && config_file.vars.is_a?(Array)
            vagrant_config.ssh.forward_env = config_file.vars
          end
        end
      end
    end
  end
end
