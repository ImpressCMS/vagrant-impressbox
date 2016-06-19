module Impressbox
  module Actions
    # Vagrant action to perform needed Impressbox actions on machine destroy command
    class MachineHalt

      # Initializer
      #
      #@param app [Object]  App instance
      #@param env [Hash]    Current loaded environment data
      def initialize(app, env)
        @app = app
      end

      # Action is called
      #
      #@param env [Hash]   Current loaded environment data
      def call(env)
        config_file = ::Impressbox::Provisioner.loaded_config
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

      # Gets path for Impressbox actions for this Vagrant action
      #
      #@return [Array]
      def dir
        File.join __dir__,
                  '..',
                  'configurators',
                  'action',
                  'machine_halt'
      end

      # Namespace used for all related Impressbox actions
      #
      #return [String]
      def namespace
        'Impressbox::Configurators::Action::MachineHalt'
      end

    end
  end
end
