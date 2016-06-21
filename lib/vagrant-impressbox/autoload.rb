# This file defines autoload paths

# First trying to do that for Impressbox namespace
module Impressbox
  autoload :Plugin, 'vagrant-impressbox/plugin.rb'
  autoload :Provisioner, 'vagrant-impressbox/provisioner.rb'
  autoload :Config, 'vagrant-impressbox/config.rb'
  autoload :Command, 'vagrant-impressbox/command.rb'

  # now for Impressbox::Objects
  module Objects
    autoload :ConfigData, 'vagrant-impressbox/objects/config_data.rb'
    autoload :ConfigFile, 'vagrant-impressbox/objects/config_file.rb'
    autoload :MassFileLoader, 'vagrant-impressbox/objects/mass_file_loader.rb'
    autoload :SshKeyDetect, 'vagrant-impressbox/objects/ssh_key_detect.rb'
    autoload :Template, 'vagrant-impressbox/objects/template.rb'
    autoload :InstanceMaker, 'vagrant-impressbox/objects/instance_maker.rb'
    autoload :Extensions, 'vagrant-impressbox/objects/extensions.rb'
  end

  # now for Impressbox::Abstract
  module Abstract
    BASE_PATH = 'vagrant-impressbox/abstract/'.freeze
    autoload :ConfiguratorPrimary, BASE_PATH + 'configurator_primary.rb'
    autoload :ConfiguratorProvision, BASE_PATH + 'configurator_provision.rb'
    autoload :ConfiguratorProviderSpecific, BASE_PATH + 'configurator_provider_specific.rb'
    autoload :ConfiguratorAction, BASE_PATH + 'configurator_action.rb'
    autoload :Extension, BASE_PATH + 'extension.rb'
  end

  # Now for actions
  module Actions
    autoload :MachineDestroy, 'vagrant-impressbox/actions/machine_destroy.rb'
    autoload :MachineUp, 'vagrant-impressbox/actions/machine_up.rb'
    autoload :MachineHalt, 'vagrant-impressbox/actions/machine_halt.rb'
  end
end
