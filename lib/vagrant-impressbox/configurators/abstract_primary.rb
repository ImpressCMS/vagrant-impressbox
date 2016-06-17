module Impressbox
  module Configurators
    # This is a base to use for other default configurators
    class AbstractPrimary
      # Do configuration tasks
      #
      #@param vagrant_config  [Object]                            Current vagrant config
      #@param config_file     [::Impressbox::Objects::ConfigFile] Loaded config file data
      def configure(vagrant_config, config_file)
        raise I18n.t('configuring.error.must_overwrite')
      end

      # This method is used for description
      #
      #@return [String]
      def description
      end

      # Can be executed ?
      #
      #@param app         [Object]                            Current vagrant config
      #@param config_file [::Impressbox::Objects::ConfigFile] Loaded config file data
      #
      #@return            [Boolean]
      def can_be_configured?(vagrant_config, file_config)
        true
      end
    end
  end
end
