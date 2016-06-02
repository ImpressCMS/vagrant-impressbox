module Impressbox
  module Actions
    class MachineDestroy

      def initialize(app, env)
        #require 'json'
        #puts JSON.dump(env)
        @app = app
        @machine = env[:machine]
      end

      def call(env)
        config_file = Impressbox::Provisioner.loaded_config
        puts config_file.inspect
        if config_file
          loader.each do |configurator|
            puts configurator.inspect
            next unless configurator.can_be_configured?(@app, env, config_file, @machine)
            env[:ui].info configurator.description if configurator.description
            configurator.configure @app, env, config_file, @machine
          end
        end

        @app.call(env)
      end

      private

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
