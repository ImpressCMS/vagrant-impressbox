# Loads all requirements
require 'vagrant'

module Impressbox
  # This class is used as dummy provisioner because all provision tasks are now defined in actions
  class Provisioner < Vagrant.plugin('2', :provisioner)
    # Cleanup script
    def cleanup
    end

    # Configure
    def configure(root_config)
    end
  end
end
