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

      errors << I18n.t('config.not_exist', {file: @file}) unless File.exist?(@file)

      { 'Impressbox' => errors }
    end
  end
end
