module Impressbox
  module Objects
    # This class is used for detecting SSh keys automatically
    class SshKeyDetect

      # Redefines UNSET_VALUE constant with shorter name
      # It's used for Vagarnt for detecting when variable value was not set
      UNSET_VALUE = ::Vagrant::Plugin::V2::Config::UNSET_VALUE

      # Private key
      #
      #@!attribute [rw] private_key
      #
      #@return [String,nil]
      attr_accessor :private_key

      # Public key
      #
      #@!attribute [rw] public_key
      #
      #@return [String,nil]
      attr_accessor :public_key

      # Initializer
      #
      #@param config [::Impressbox::Objects::ConfigFile] Loaded config file data
      def initialize(config)
        keys_from_config config.keys
        unless validate
          detect_ssh_keys_from_config
          unless validate
            detect_from_filesystem
            validate
          end
        end
      end

      # Sets keys from config
      #
      #@param keys [Hash] Keys data
      def keys_from_config(keys)
        if !keys[:private].nil? && (keys[:private] != UNSET_VALUE)
          @private_key = keys[:private]
        end
        if !keys[:public].nil? && (keys[:public] != UNSET_VALUE)
          @public_key = keys[:public]
        end
      end

      # Are both keys variables empty?
      #
      #@return [Boolean]
      def empty?
        @private_key.nil? && @public_key.nil?
      end

      # Was private key variable set ?
      #
      #@return [Boolean]
      def private_key?
        !@private_key.nil?
      end

      # Was public key variable set ?
      #
      #@return [Boolean]
      def public_key?
        !@public_key.nil?
      end

      # Checks if both keys were set and files exists
      #
      #@return [Boolean]
      def validate
        return false unless private_key?
        return false unless public_key?
        File.exist?(@private_key) && File.exist?(@public_key)
      end

      # Try detect SSH keys by using only a config
      def detect_ssh_keys_from_config
        if private_key?
          @public_key = @private_key + '.pub'
        elsif public_key?
          @private_key = private_filename_from_public(@public_key)
        end
      end

      # Try detect SSH keys by using local filesystem
      def detect_from_filesystem
        ssh_keys_search_paths.each do |dir|
          iterate_dir_fs dir
          break unless empty?
        end
      end

      # Used in detect_ssh_keys_from_filesystem
      #
      #@param dir [String] Dir where to search SSH keys files
      #
      #@return [String]
      def iterate_dir_fs(dir)
        Dir.entries(dir).each do |entry|
          entry = File.join(dir, entry)
          next unless good_file_on_filesystem?(entry)
          @private_key = private_filename_from_public(entry)
          @public_key = entry
          break
        end
      end

      # Converts private SSH key to public
      #
      #@param filename [String] Public SSH key filename
      #
      #@return [String]
      def private_filename_from_public(filename)
        File.join(
          File.dirname(
            filename
          ),
          File.basename(
            filename,
            '.pub'
          )
        )
      end

      # Is a correct file in filesystem tobe a SSH key?
      #
      #@param filename [String] Filename to test
      #
      #@return [Boolean]
      def good_file_on_filesystem?(filename)
        File.file?(filename) && \
          File.extname(filename).eql?('.pub') && \
          File.exist?(private_filename_from_public(filename))
      end

      # Gets paths for looking for SSH keys
      #
      #@return [Array]
      def ssh_keys_search_paths
        [
          File.join(__dir__, '.ssh'),
          File.join(__dir__, 'ssh'),
          File.join(__dir__, 'keys'),
          File.join(Dir.home, '.ssh'),
          File.join(Dir.home, 'keys')
        ].reject do |dir|
          !Dir.exist?(dir)
        end
      end
    end
  end
end
