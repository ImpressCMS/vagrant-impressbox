# Loads all requirements
require 'vagrant'

# Impressbox namepsace
module Impressbox
  # Vagrant config class
  class Config < Vagrant.plugin('2', :config)
    # Filename from where to read all config data
    #
    # @!attribute [rw] file
    #
    # @return [String]
    attr_accessor :file

    # Initializer
    def initialize
      @file = UNSET_VALUE
    end

    # Finalize config
    def finalize!
      @file = 'config.yaml' if @file == UNSET_VALUE
    end

    # Gets ConfigFile instance from set file attribute
    #
    #@return [::Impressbox::Objects::ConfigFile]
    def file_config
      unless @file_config_data
        require_relative File.join('objects', 'config_file')
        @file_config_data = Impressbox::Objects::ConfigFile.new(@file)
      end
      @file_config_data
    end

    # Validate config values
    #
    #@param machine [::Vagrant::Machine] machine for what to validate config data
    #
    #@return [Hash]
    def validate(machine)
      errors = []

      unless good_file?
        errors << I18n.t('config.not_exist', file: @file)
      end

      {'Impressbox' => errors}
    end

    private

    # Does yaml file exists?
    #
    #@return [Boolean]
    def good_file?
      File.exist? @file
    end

  end
end
