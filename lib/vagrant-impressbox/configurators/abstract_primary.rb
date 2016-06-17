module Impressbox
  module Configurators
    # This is a base to use for other default configurators
    class AbstractPrimary
      # This method is used to configure/run configurator
      def configure(_vagrant_config, _config_file)
        raise I18n.t('configuring.error.must_overwrite')
      end

      # This method is used for description
      def description
      end

      # Is method validates if can be executed
      def can_be_configured?(_vagrant_config, _file_config)
        true
      end
    end
  end
end
