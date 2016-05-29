# This file defines autoload paths

# First trying to do that for Impressbox namespace
module Impressbox
  autoload :Plugin, 'vagrant-impressbox/plugin'
  autoload :Provisioner, 'vagrant-impressbox/provisioner'
  autoload :Config, 'vagrant-impressbox/config'
  autoload :Command, 'vagrant-impressbox/command'

  # now for Impressbox::Objects
  module Objects
    autoload :ConfigData, 'vagrant-impressbox/objects/config_data'
    autoload :ConfigFile, 'vagrant-impressbox/objects/config_file'
    autoload :MassFileLoader, 'vagrant-impressbox/objects/mass_file_loader'
    autoload :SSHKeyDetect, 'vagrant-impressbox/objects/ssh_key_detect'
    autoload :Template, 'vagrant-impressbox/objects/template'
  end

  # now for Impressbox::Configurators
  module Configurators
    # now for Impressbox::Configurators::Base
    module Base
      BASE_PATH = 'vagrant-impressbox/configurators/base'.freeze
      autoload :Default, BASE_PATH + '/default'
      autoload :Provision, BASE_PATH + '/provision'
      autoload :ProviderSpecific, BASE_PATH + '/provider_specific'
    end
  end
end
