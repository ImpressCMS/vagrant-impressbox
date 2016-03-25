module Impressbox
  module Vagrant
    # Info about vagrant
    class Info
      # Provider
      @provider = nil

      # Api version
      @api_version = '2'.freeze

      # Initializer
      def initialize
        @provider = @detect_provider
      end

      # Detecting provider
      def detect_provider
        if ARGV[1] && (ARGV[1].split('=')[0] == '--provider' || ARGV[2])
          return (ARGV[1].split('=')[1] || ARGV[2])
        end
        (ENV['VAGRANT_DEFAULT_PROVIDER'] || :virtualbox).to_sym
      end

      # Make some methods private
      private :detect_provider
    end
  end
end
