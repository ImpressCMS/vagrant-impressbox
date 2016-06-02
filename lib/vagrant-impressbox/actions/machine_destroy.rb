module Impressbox
  module Actions
    class MachineDestroy

      def initialize(app, env)
        @app = app
      end

      def call(env)
        run_configurators

        @app.call(env)
      end

      private

      def run_configurators
        loader.each do |configurator|
          next unless configurator.can_be_configured?(app, env, config_file)
          @machine.ui.info configurator.description if configurator.description
          configurator.configure app, env, config_file
        end
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
