module Impressbox
  module Configurators
    module Base
      # This is a base to use for other default configurators
      class Default
        def configure(_vagrant_config, _config_file)
          raise I18n.t('configuring.error.must_overwrite')
        end

        def description
        end

        def can_be_configured?(_vagrant_config, _file_config)
          true
        end
      end
    end
  end
end
