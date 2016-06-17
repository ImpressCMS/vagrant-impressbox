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
    autoload :SshKeyDetect, 'vagrant-impressbox/objects/ssh_key_detect'
    autoload :Template, 'vagrant-impressbox/objects/template'
  end

  # now for Impressbox::Configurators
  module Configurators
    BASE_PATH = 'vagrant-impressbox/configurators/'.freeze
    autoload :AbstractPrimary, BASE_PATH + 'abstract_primary'
    autoload :AbstractProvision, BASE_PATH + 'abstract_provision'
    autoload :AbstractProviderSpecific, BASE_PATH + 'abstract_provider_specific'
    autoload :AbstractAction, BASE_PATH + 'abstract_action'
  end

  # Now for actions
  module Actions
    autoload :MachineDestroy, 'vagrant-impressbox/actions/machine_destroy'
    autoload :MachineUp, 'vagrant-impressbox/actions/machine_up'
    autoload :MachineHalt, 'vagrant-impressbox/actions/machine_halt'
  end
end
