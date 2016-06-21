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
        config = convert(config_file.to_hash)
        Homestead.configure vagrant_config, config
      end

      private

      # Updates config data
      #
      #@param data [Hash] Source data
      #
      #@return [Hash]
      def convert(data)
        ret = data.dup
        ret['keys'] = [
          data['keys']['private']
        ]
        ret['authorize'] = data['keys']['public']
        ret['folders'] = [
          {
            "map" => "www",
            'to' => "/vagrant/www"
          }
        ]
        ret['sites'] = [
          {
            "map" => "www",
            'to' => "/vagrant/www/public"
          }
        ]
        ret['databases'] = [
          'app'
        ]
        if data['vars'].nil? || !data['vars'].kind_of?(Array)
          ret['variables'] = []
        else
          ret['variables'] = data['vars']
        end
        ret
      end

    end
  end
end
