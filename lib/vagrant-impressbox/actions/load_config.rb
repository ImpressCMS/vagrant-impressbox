module Impressbox
  module Actions
    # Configure from config
    class LoadConfig
      def initialize(app, env)
        @app = app
        env[:impressbox] = {
          :enabled => provision_enabled?(env)
        };
      end

      def call(env)
        @app.call env
        if env[:impressbox][:enabled]
          env[:impressbox][:config] = xaml_config(env)
        end
      end

      private

      # Is ImpressBox provisioner enabled
      def provision_enabled?(env)
        env[:machine].config.vm.provisioners.each do |provisioner|
          return true if provisioner.type == :impressbox
        end
        false
      end

      # load xaml config
      def xaml_config(env)
        require_relative File.join('..', 'objects', 'config_file')
        if env[:machine].config.impressbox and env[:machine].config.impressbox.file.is_a? String
          file = env[:machine].config.impressbox.file
        else
          file = "config.yaml"
        end
        env[:ui].info I18n.t('config.loaded_from_file', {:file => file})
        Impressbox::Objects::ConfigFile.new file
      end
    end
  end
end
