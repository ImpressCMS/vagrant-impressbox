module Impressbox
  module Actions
    class MachineUp

      def initialize(app, env)
        @app = app
      end

      def call(env)
        config_file = Impressbox::Provisioner.loaded_config
        machine = env[:machine]
        loader.each do |configurator|
          next unless configurator.can_be_configured?(@app, env, config_file, machine)
          env[:ui].info configurator.description if configurator.description
          configurator.configure @app, env, config_file, machine
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
                  'machine_up'
      end

      def namespace
        'Impressbox::Configurators::Action::MachineUp'
      end

    end
  end
end
