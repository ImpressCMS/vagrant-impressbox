module Impressbox
  module Actions
    # This is a base action to use for other actions
    class BaseAction

      # Returns app instance
      attr_reader :app

      # Returns object for UI operations
      attr_reader :ui

      def initialize(app, env)
        @app = app
        @ui = env[:ui]
      end

      def call(env)
        if env[:impressbox][:enabled] and can_be_configured?(env[:impressbox][:config])
          desc = description
          if !desc.nil? and desc
            @ui.info description
          end
          if modify_config?
            env[:impressbox][:config] = configure(env[:machine], env[:impressbox][:config])
          else
            configure env[:machine], env[:impressbox][:config]
          end
        end

        @app.call env
      end

      private

      def configure(machine, config)
        raise I18n.t('configuring.error.must_overwrite')
      end

      def description

      end

      def modify_config?
        false
      end

      def can_be_configured?(config)
        true
      end

    end
  end
end
