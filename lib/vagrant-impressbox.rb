begin
  require 'vagrant'
rescue LoadError
  raise 'vagrant-impressbox plugin must be run within Vagrant'
end

# Loads all module data
module Impressbox
  require 'vagrant-impressbox/version'
  require 'vagrant-impressbox/plugin'

  # This returns the path to the source of this plugin.
  #
  # @return [Pathname]
  def self.source_root
    @source_root ||= Pathname.new(File.expand_path('../../', __FILE__))
  end

  I18n.load_path << File.expand_path('locales/en.yml', source_root)
  I18n.reload!
end
