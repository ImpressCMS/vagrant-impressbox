# Loads all requirements
require 'vagrant'

# Impressbox namepsace
module Impressbox
  # Vagrant config class
  class Config < Vagrant.plugin('2', :config)
    # Filename from where to read all config data
    #
    # @!attribute [r] file
    #
    # @return [String]
    attr_reader :file

    # Extension used when dealing
    #
    # @!attribute [r] extension
    #
    # @return [String,nil]
    attr_reader :extension

    # Initializer
    def initialize
      @file = UNSET_VALUE
      @extension = UNSET_VALUE
    end

    # Finalize config
    def finalize!
      @file = 'config.yaml' if @file == UNSET_VALUE
      @extension = nil if @extension == UNSET_VALUE
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

      unless good_extension?
        errors << I18n.t('confi1g.bad_extension', extension: @extension)
      end

      {'Impressbox' => errors}
    end

    private

    # Does yaml file exists?
    #
    #@return [Boolean]
    def good_file?
      File.exist?(@file)
    end

    # Does extension file exists?
    #
    #@return [Boolean]
    def good_extension?
      return true if @extension == nil
      ext =@extension + ".rb"
      File.exist? File.join(__dir__, 'extensions',ext.downcase )
    end

  end
end
