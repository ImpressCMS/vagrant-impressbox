module Impressbox
  module Actions
    class MachineDestroy

      def initialize(app, env)
        #require 'json'
        #puts JSON.dump(env)
        @app = app
      end

      def call(env)
        config_file = load_impressbox_config(env[:machine])
        if config_file
          loader.each do |configurator|
            next unless configurator.can_be_configured?(@app, env, config_file, env[:machine])
            env[:ui].info configurator.description if configurator.description
            configurator.configure @app, env, config_file, env[:machine]
          end
        end

        @app.call(env)
      end

      private

      def load_impressbox_config(machine)
        ::Impressbox::Objects::ConfigFile.load_from_root_config machine.env.vagrantfile.config
      end

      # load xaml config
      def xaml_config(root_config)

        Impressbox::Objects::ConfigFile.new file
      end

      def loader
        Impressbox::Objects::MassFileLoader.new(
          namespace,
          dir
        )
      end

      def dir
        File.join __dir__,
                  '..',
                  'configurators',
                  'action',
                  'machine_destroy'
      end

      def namespace
        'Impressbox::Configurators::Action::MachineDestroy'
      end

    end
  end
end
