module Impressbox
  module Extensions
    # Extension for using with Laravel Homestead
    class LaravelHomestead < Impressbox::Abstract::Extension

      # Returns Hash with required libraries
      #
      #@return [Hash]
      def require_libraries
        return {
          'homestead' => 'git@github.com:laravel/homestead.git'
        }
      end

      # Configure with extra settings
      #
      #@param vagrant_config  [Object]                            Current vagrant config
      #@param config_file     [::Impressbox::Objects::ConfigFile] Loaded config file data
      def configure(vagrant_config, config_file)
        require_file 'homestead', 'scripts/homestead.rb'
        Homestead.configure vagrant_config, convert(config_file.to_hash)
      end

      private

      # Updates config data
      #
      #@param data [Hash] Source data
      #
      #@return [Hash]
      def convert(data)
        data['authorize'] = data.keys.public_key.dup
        data['keys'] = [
          data.keys.private_key.dup
        ]
        data['folders'] = [
          {
            "map" => "www",
            'to' => "/vagrant/www"
          }
        ]
        data['sites'] = [
          {
            "map" => "www",
            'to' => "/vagrant/www/public"
          }
        ]
        data['databases'] = [
          'app'
        ]
        data['variables'] = data.vars
        data
      end

    end
  end
end
