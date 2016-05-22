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
        exec_action env if should_be_executed?(env)

        @app.call env
      end

      private

      def should_be_executed?(env)
        return false unless env[:impressbox][:enabled]
        can_be_configured? env[:impressbox][:config]
      end

      def exec_action(env)
        desc = description
        @ui.info description if !desc.nil? && desc
        ret = configure(env[:machine], env[:impressbox][:config])
        env[:impressbox][:config] = ret if modify_config?
      end

      def configure(_machine, _config)
        raise I18n.t('configuring.error.must_overwrite')
      end

      def description
      end

      def modify_config?
        false
      end

      def can_be_configured?(_config)
        true
      end
    end
  end
end
