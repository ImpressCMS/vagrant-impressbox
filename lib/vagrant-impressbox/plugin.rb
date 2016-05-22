# Loads all requirements
require 'vagrant'

# Plugin definition
class Impressbox::Plugin < Vagrant.plugin(2)
  name 'vagrant-impressbox'

  description I18n.t('description')

  config(:impressbox, :provisioner) do
    require_relative 'config'
    Impressbox::Config
  end

  provisioner(:impressbox) do
    require_relative 'provisioner'
    Impressbox::Provisioner
  end

  action_hook(:impressbox) do |hook|
    require_relative 'action_builder'
    hook.after(
      Vagrant::Action::Builtin::Provision,
      Impressbox::ActionBuilder.provision_tasks_before
    )
    hook.after(
      Vagrant::Action::Builtin::WaitForCommunicator,
      Impressbox::ActionBuilder.provision_tasks_after
    )
  end

  command 'impressbox' do
    require_relative 'command'
    Impressbox::Command
  end
end
