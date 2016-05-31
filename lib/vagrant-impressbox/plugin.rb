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
  end
end
