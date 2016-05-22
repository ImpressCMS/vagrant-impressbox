module Impressbox
  module Actions
    # This is a base action to use for other actions
    class BaseAction

      # Shared data between instances
      @@data = {}

      # Returns app instance
      attr_reader :app

      # Returns object for UI operations
      attr_reader :ui

      def self.data
        @@data
      end

      def initialize(app, env)
        @app = app
        if env.key?(:ui)
          @ui = env[:ui]
        else
          @ui = env[:env].ui
        end
      end

      def call(env)
        exec_action env if should_be_executed?(env)

        @app.call env
      end

      private

      def should_be_executed?(env)
        return false unless @@data[:enabled]
        can_be_configured? @@data[:config]
      end

      def exec_action(env)
        desc = description
        @ui.info description if !desc.nil? && desc
        ret = configure(make_data(env))
        @@data[:config] = ret if modify_config?
      end

      def make_data(env)
        params = {}
        params[:config] = @@data[:config] if @@data.key?(:config)
        if env.key?(:env) && env[:env].vagrantfile
          params[:vagrantfile] = env[:env].vagrantfile.config
        end
        params[:machine] = env[:machine] if env.key?(:machine)
        params
      end

      def configure(data)
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
