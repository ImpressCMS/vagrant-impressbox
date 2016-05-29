module Impressbox
  module Configurators
    module Default
  # Configures default SSH configuration
      class ConfigureSSH < Impressbox::Configurators::Default
    def description
      I18n.t 'configuring.ssh'
    end

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
