# Loads all requirements
require 'vagrant'

# Plugin definition
class Impressbox::Plugin < Vagrant.plugin(2)
  @@data = {}

  name 'impressbox'

  description I18n.t('description')

  def self.set_item(property, value)
    @@data[property] = value
  end

  def self.get_item(property)
    @@data[property]
  end

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
      Impressbox::ActionBuilder.insert_key
    )
    hook.after(
      Vagrant::Action::Builtin::Provision,
      Impressbox::ActionBuilder.copy_git_settings
    )
  end

  command 'impressbox' do
    require_relative 'command'
    Impressbox::Command
  end
end
