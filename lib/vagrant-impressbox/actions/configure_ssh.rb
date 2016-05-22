require_relative 'base_action'

module Impressbox
  module Actions
    # Configures default SSH configuration
    class ConfigureSSH < BaseAction
      private

      def description
        I18n.t 'configuring.ssh'
      end

      def configure(data)
        # @config.ssh.insert_key = true
        data[:vagrantfile].ssh.pty = false
        data[:vagrantfile].ssh.forward_x11 = false
        data[:vagrantfile].ssh.forward_agent = false
        if !data[:config].vars.nil? && data[:config].vars.is_a?(Array)
          data[:vagrantfile].ssh.forward_env = data[:config].vars
        end
      end
    end
  end
end
