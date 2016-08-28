# This file defines autoload paths

# First trying to do that for Impressbox namespace
module Impressbox
  autoload :Plugin, 'vagrant-impressbox/plugin.rb'
  autoload :Provisioner, 'vagrant-impressbox/provisioner.rb'
  autoload :Command, 'vagrant-impressbox/command.rb'
  autoload :Config, 'vagrant-impressbox/config.rb'

  # now for Impressbox::Objects
  module Objects
    BASE_PATH = 'vagrant-impressbox/objects/'.freeze

    autoload :ConfigData, BASE_PATH + 'config_data.rb'
    autoload :ConfigFile, BASE_PATH + 'config_file.rb'
    autoload :MassFileLoader, BASE_PATH + 'mass_file_loader.rb'
    autoload :SshKeyDetect, BASE_PATH + 'ssh_key_detect.rb'
    autoload :Template, BASE_PATH + 'template.rb'
    autoload :InstanceMaker, BASE_PATH + 'instance_maker.rb'
    autoload :CommandOptionsParser, BASE_PATH + 'command_options_parser.rb'
    autoload :MustacheExt, BASE_PATH + 'mustache_ext.rb'
  end

  # now for Impressbox::Abstract
  module Abstract
    BASE_PATH = 'vagrant-impressbox/abstract/'.freeze

    autoload :ConfiguratorPrimary, BASE_PATH + 'configurator_primary.rb'
    autoload :ConfiguratorProvision, BASE_PATH + 'configurator_provision.rb'
    autoload :ConfiguratorProviderSpecific, BASE_PATH + 'configurator_provider_specific.rb'
    autoload :ConfiguratorAction, BASE_PATH + 'configurator_action.rb'
    autoload :Extension, BASE_PATH + 'extension.rb'
    autoload :CommandHandler, BASE_PATH + 'command_handler.rb'
    autoload :CommandSpecialArg, BASE_PATH + 'command_special_arg.rb'
  end

  # Now for actions
  module Actions
    BASE_PATH = 'vagrant-impressbox/actions/'.freeze

    autoload :MachineUp, BASE_PATH + 'machine_up.rb'
    autoload :MachineHalt, BASE_PATH + 'machine_halt.rb'
  end
end
