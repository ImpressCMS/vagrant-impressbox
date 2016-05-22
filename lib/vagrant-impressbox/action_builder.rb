require_relative File.join('actions', 'load_config')
require_relative File.join('actions', 'insert_key')
require_relative File.join('actions', 'copy_git_settings')
require_relative File.join('actions', 'configure_network')
require_relative File.join('actions', 'configure_hosts')
require_relative File.join('actions', 'configure_ssh')
require_relative File.join('actions', 'configure_provision')
require_relative File.join('actions', 'do_special_provider_configuration')
require_relative File.join('actions', 'do_primary_configuration')

module Impressbox
  # Defines builder for actions
  module ActionBuilder
    include Vagrant::Action::Builtin

    def self.provision_tasks_before
      Vagrant::Action::Builder.new.tap do |builder|
        builder.use Impressbox::Actions::LoadConfig
        builder.use Impressbox::Actions::DoPrimaryConfiguration
        builder.use Impressbox::Actions::DoSpecialProviderConfiguration
        builder.use Impressbox::Actions::ConfigureNetwork
        builder.use Impressbox::Actions::ConfigureHosts
        builder.use Impressbox::Actions::ConfigureSSH
        builder.use Impressbox::Actions::ConfigureProvision
      end
    end

    def self.provision_tasks_after
      Vagrant::Action::Builder.new.tap do |builder|
        builder.use Impressbox::Actions::CopyGitSettings
        builder.use Impressbox::Actions::InsertKey
      end
    end
  end
end
