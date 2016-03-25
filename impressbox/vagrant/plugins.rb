module Impressbox
  module Vagrant
    # Vagrant plugins management
    class Plugins
      # Defines required vagrant plugins
      PLUGINS = [
        'vagrant-hostmanager'
      ].freeze

      # Initializer
      def initialize(vagrant)
        @vagrant = vagrant
        load if ARGV.include?('up')
      end

      # Loads all plugins defined in VAGRANT_PLUGINS constant
      def load
        needed_reboot = false
        PLUGINS.each do |plugin|
          unless @vagrant.has_plugin?(plugin)
            system 'vagrant plugin install ' + plugin
            needed_reboot = true
          end
        end
        return unless needed_reboot
        system 'vagrant up'
        exit true
      end

      # make some methods private
      private :load
    end
  end
end
