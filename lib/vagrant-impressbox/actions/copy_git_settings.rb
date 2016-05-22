require_relative 'base_action'

module Impressbox
  module Actions
    # Copies global git settings from host to guest
    class CopyGitSettings < BaseAction
      private

      def description
        I18n.t('copying.git_settings')
      end

      def configure(machine, _config)
        update_remote_cfg machine, local_cfg
      end

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

      def update_remote_cfg(machine, cfg)
        machine.communicate.wait_for_ready 300

        cfg.each do |key, name|
          machine.communicate "git config --global #{key} '#{name}'"
        end
      end
    end
  end
end
