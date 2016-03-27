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

    def validate(_machine)
      errors = []

      errors << "Config file #{@file} not exist" unless File.exist?(@file)

      unless (@enabled == false) || (@enabled == true)
        errors << 'Enabled must be have a boolean value'
      end

      { 'Impressbox' => errors }
    end
  end
end
