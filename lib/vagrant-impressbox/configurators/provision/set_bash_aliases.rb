module Impressbox
  module Configurators
    module Provision
      # Configures bash aliases
      class SetBashAliases < Impressbox::Abstract::ConfiguratorProvision

        # Returns description
        #
        #@return [String]
        def description
          I18n.t 'configuring.bash_aliases'
        end

        # Can be executed ?
        #
        #@param machine     [::Vagrant::Machine]                Current machine
        #@param config_file [::Impressbox::Objects::ConfigFile] Loaded config file data
        #
        #@return            [Boolean]
        def can_be_configured?(machine, config_file)
          File.exists? bash_aliases_file
        end

        # Configure machine on provision
        #
        #@param machine         [::Vagrant::Machine]                Current machine
        #@param config_file     [::Impressbox::Objects::ConfigFile] Loaded config file data
        def configure(machine, config_file)
          vagrant_config.vm.provision "file", source: aliasesPath, destination: "~/.bash_aliases"
        end


        private

        # Gets local Bash aliases file
        #
        #@return [String]
        def bash_aliases_file
          File.join (
            File.expand_path("~/.homestead"), "aliases"
          )
        end
      end
    end
  end
