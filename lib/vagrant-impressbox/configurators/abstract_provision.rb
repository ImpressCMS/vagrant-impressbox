# Impressbox namespace
module Impressbox
  module Configurators
      # Base class used for provision tasks
      class AbstractProvision
        # This method is used to configure/run configurator
        def configure(_machine, _config_file)
          raise I18n.t('configuring.error.must_overwrite')
        end

        # This method is used for description
        def description
        end

        # Is method validates if can be executed
        def can_be_configured?(_machine, _config_file)
          true
        end
      end
  end
end
