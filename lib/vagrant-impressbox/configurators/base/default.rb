module Impressbox::Configurators::Base
    # This is a base to use for other default configurators
    class Default

      def configure(vagrant_config, config_file)
        raise I18n.t('configuring.error.must_overwrite')
      end

      def description
      end

      def can_be_configured?(vagrant_config, file_config)
        true
      end

    end
end
