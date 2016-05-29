# Impressbox namespace
module Impressbox
  module Configurators
      # Base class used for provision tasks
      class AbstractProvision
        def configure(_machine, _config_file)
          raise I18n.t('configuring.error.must_overwrite')
        end

        def description
        end

        def can_be_configured?(_machine, _config_file)
          true
        end
      end
  end
end
