module Impressbox
  module Configurators
    # This is a base to use for action based configurators
    class AbstractAction
      # This method is used to configure/run configurator
      def configure(app, env, config_file, machine)
        raise I18n.t('configuring.error.must_overwrite')
      end

      # This method is used for description
      def description
      end

      # Is method validates if can be executed
      def can_be_configured?(app, env, config_file, machine)
        true
      end
    end
  end
end
