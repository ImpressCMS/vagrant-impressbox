module Impressbox
  module Objects
    # Config class
    class Config < Impressbox::Objects::Base
      # config data
      @_config = []    

      # method for fast reading all config to variable
      def self.read
        instance = new
        instance.config
      end

      # Initializer
      def initialize
        file = detect_yaml_config        
        error 'config.yaml not found.' if file.nil?
        @_config = load_config
      end
      
      # returns config
      def config
        @_config
      end

      # Loads configuration
      def load_config
        require 'yaml'

        begin
          YAML.load	File.open(@config_file)
        rescue ArgumentError => e
          error "Could not parse YAML: #{e.message}"
        end
      end

      # Detect config.yaml location
      def detect_yaml_config
        if File.exist? File.join(Impressbox.app_path(), 'config.yaml')
          return File.join(Impressbox.app_path(), 'config.yaml')
        elsif File.exist? File.join(ENV['vbox_config_path'], 'config.yaml')
          return File.join(ENV['vbox_config_path'], 'config.yaml')
        end
        nil
      end

      # Makes some methods private
      private :load_config,
              :detect_yaml_config
    end
  end
end
