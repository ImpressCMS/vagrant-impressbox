# Impressbox namespace
module Impressbox
  module Configurators
    module Base
      class Provision

        def configure(machine, config_file)
          raise I18n.t('configuring.error.must_overwrite')
        end

        def description
        end

        def can_be_configured?(machine, config_file)
          true
        end

      end
    end
  end
end
