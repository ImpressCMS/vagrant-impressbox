# Loads all requirements
require 'vagrant'
require 'vagrant-impressbox/autoload'

# Plugin definition
module Impressbox
  class Plugin < Vagrant.plugin(2)
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

    command 'impressbox' do
      require_relative 'command'
      Impressbox::Command
    end
  end
end
