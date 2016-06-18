module Impressbox
  module Actions
    # Vagrant action to perform needed Impressbox actions on machine destroy command
    class MachineDestroy

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
<<<<<<< HEAD:lib/vagrant-impressbox/actions/machine_destroy.rb
        config_file = ::Impressbox::Provisioner.loaded_config
=======
        config_file = load_impressbox_config(env[:machine])
>>>>>>> f77de7a8d112dbce49312618316bbe9083368319:lib/vagrant-impressbox/actions/machine_halt.rb
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

<<<<<<< HEAD:lib/vagrant-impressbox/actions/machine_destroy.rb
      # Gets preconfigured loader instance
      #
      #return [::Impressbox::Objects::MassFileLoader]
=======
      def load_impressbox_config(machine)
        ::Impressbox::Objects::ConfigFile.load_from_root_config machine.env.vagrantfile.config
      end

      # load xaml config
      def xaml_config(root_config)

        Impressbox::Objects::ConfigFile.new file
      end

>>>>>>> f77de7a8d112dbce49312618316bbe9083368319:lib/vagrant-impressbox/actions/machine_halt.rb
      def loader
        ::Impressbox::Objects::MassFileLoader.new(
          namespace,
          dir
        )
      end

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
