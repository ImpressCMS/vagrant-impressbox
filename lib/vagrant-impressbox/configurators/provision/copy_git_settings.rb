module Impressbox
  module Configurators
    module Provision
      # Copies global git settings from host to guest
      class CopyGitSettings < Impressbox::Abstract::ConfiguratorProvision

        # Returns description
        #
        #@return [String]
        def description
          I18n.t('copying.git_settings')
        end

        # Configure machine on provision
        #
        #@param machine         [::Vagrant::Machine]                Current machine
        #@param config_file     [::Impressbox::Objects::ConfigFile] Loaded config file data
        def configure(machine, config_file)
          @machine = machine
          update_remote_cfg machine, local_cfg
        end

        private

        # Returns host GIT config
        #
        #@return [Hash]
        def local_cfg
          ret = {}
          begin
          output = `git config --list --global`
          output.lines.each do |line|
            line.split(' ', 2) do |name, value|
              ret[name] = value
            end
          end
          rescue Exception => e
            @machine.ui.error I18n.t('configuring.error.git_app_not_found')
          end
          ret
        end

        # Sets GIT settings on guest machine
        #
        #@param machine [::Vagrant::Machine]  Current machine
        #@param cfg     [Hash]                Git settings
        def update_remote_cfg(machine, cfg)
          machine.communicate.wait_for_ready 300

          cfg.each do |key, name|
            machine.communicate "git config --global #{key} '#{name}'"
          end
        end
      end
    end
  end
end
