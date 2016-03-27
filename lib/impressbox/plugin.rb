# Loads all requirements
require 'vagrant'

# Plugin definition
class Impressbox::Plugin < Vagrant.plugin(2)
  name 'impressbox'

  description <<-DESC
  This plugin adds possibility to create and manage box with configuration defined in YAML file.
  This plugin is created for developing something with ImpressCMS but it's possible to use also with other CMS'es and framework.
DESC

  config('impressbox', :provisioner) do
    require_relative 'config'
    Impressbox::Config
  end

  provisioner 'impressbox' do
    require_relative 'provisioner'
    Impressbox::Provisioner
  end

  command 'impressbox' do
    require_relative 'command'
    Impressbox::Command
  end
end
