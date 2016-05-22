require_relative 'base_action'

module Impressbox
  module Actions
    # Configure from config
    class LoadConfig < BaseAction
      def initialize(app, env)
        super app, env
        env[:impressbox] = {
          :enabled => provision_enabled?(env)
        };
      end

      private

      def modify_config?
        true
      end

      def description
        I18n.t 'config.loading'
      end

      def configure(machine, config)
        xaml_config machine
      end

      # Is ImpressBox provisioner enabled
      def provision_enabled?(env)
        env[:machine].config.vm.provisioners.each do |provisioner|
          return true if provisioner.type == :impressbox
        end
        false
      end

      # load xaml config
      def xaml_config(machine)
        require_relative File.join('..', 'objects', 'config_file')
        if machine.config.impressbox and machine.config.impressbox.file.is_a? String
          file = machine.config.impressbox.file
        else
          file = "config.yaml"
        end
        @ui.info I18n.t('config.loaded_from_file', {:file => file})
        Impressbox::Objects::ConfigFile.new file
      end
    end
  end
end
