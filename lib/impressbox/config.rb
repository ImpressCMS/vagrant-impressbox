# Loads all requirements
require 'vagrant'

# Impressbox namepsace
module Impressbox
  # Vagrant config class
  class Config < Vagrant.plugin('2', :config)
    # @!attribute file
    #   @return [string] Filename from where to read all config data
    attr_reader :file

    def initialize
      @file = UNSET_VALUE
    end

    def finalize!
      @file = 'config.yaml' if @file == UNSET_VALUE
    end

    def file_config
      unless @file_config_data
        require_relative File.join('objects', 'config_file')
        @file_config_data = Impressbox::Objects::ConfigFile.new(@file)
      end
      @file_config_data
    end

    def validate(_machine)
      errors = []

      unless File.exist?(@file)
        errors << I18n.t('config.not_exist', file: @file)
      end

      { 'Impressbox' => errors }
    end
  end
end
