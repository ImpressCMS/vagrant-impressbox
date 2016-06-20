module Impressbox
  module Configurators
    module Provision
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
          p = config_file.provision
          return false unless p.is_a?(String)
          p.strip!
          !p.empty?
        end

        # Configure machine on provision
        #
        #@param machine         [::Vagrant::Machine]                Current machine
        #@param config_file     [::Impressbox::Objects::ConfigFile] Loaded config file data
        def configure(machine, config_file)
          machine.action :ssh_run,
                         ssh_run_command: config_file.provision,
                         ssh_opts: {
                           extra_args: []
                         }
        end
      end
    end
  end
end
