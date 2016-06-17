module Impressbox
  module Configurators
    # This is a base to use for action based configurators
    class AbstractAction
      # This method is used to configure/run configurator
      #
      #@param app         [Object]                            App instance
      #@param env         [Hash]                              Current loaded environment data
      #@param config_file [::Impressbox::Objects::ConfigFile] Loaded config file data
      #@param machine     [::Vagrant::Machine]                Current machine
      def configure(app, env, config_file, machine)
        raise I18n.t('configuring.error.must_overwrite')
      end

      # This method is used for description
      #
      #@return [String]
      def description
      end

      # Can be executed ?
      #
      #@param app         [Object]                            App instance
      #@param env         [Hash]                              Current loaded environment data
      #@param config_file [::Impressbox::Objects::ConfigFile] Loaded config file data
      #@param machine     [::Vagrant::Machine]                Current machine
      #
      #@return            [Boolean]
      def can_be_configured?(app, env, config_file, machine)
        true
      end
    end
  end
end
