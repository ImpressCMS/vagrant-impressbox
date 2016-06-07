# Loads all requirements
require 'vagrant'
require 'vagrant-impressbox/autoload'

# Plugin definition
module Impressbox
  class Plugin < Vagrant.plugin(2)
    name 'vagrant-impressbox'

    description I18n.t('description')

    config(:impressbox) do
      Impressbox::Config
    end

    provisioner(:impressbox) do
      Impressbox::Provisioner
    end

    command 'impressbox' do
      Impressbox::Command
    end

    action_hook(:machine_action_up) do |hook|
      require_relative 'action'
      hook.after Vagrant::Action::Builtin::Provision, Action.machine_up
    end

    action_hook(:machine_action_destroy) do |hook|
      require_relative 'action'
      hook.after Vagrant::Action::Builtin::GracefulHalt, Action.machine_halt
    end

  end
end
