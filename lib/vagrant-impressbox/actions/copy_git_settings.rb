module Impressbox
  module Actions
    # Copies global git settings from host to guest
    class CopyGitSettings
      def initialize(app, _env)
        @app = app
      end

      def call(env)
        @app.call env
        if env[:impressbox][:enabled]
          @machine = env[:machine]
          env[:ui].info I18n.t('copying.git_settings')
          update_remote_cfg local_cfg
        end
      end

      private

      def local_cfg
        ret = {}
        output = `git config --list --global`
        output.lines.each do |line|
          line.split(' ', 2) do |name, value|
            ret[name] = value
          end
        end
        ret
      end

      def update_remote_cfg(cfg)
        @machine.communicate.wait_for_ready 300

        cfg.each do |key, name|
          @machine.communicate "git config --global #{key} '#{name}'"
        end
      end
    end
  end
end
