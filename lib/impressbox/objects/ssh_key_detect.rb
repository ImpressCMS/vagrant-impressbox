module Impressbox
  module Objects
    # This class is used for detecting SSh keys automatically
    class SshKeyDetect
      UNSET_VALUE = ::Vagrant::Plugin::V2::Config::UNSET_VALUE

      # @!attribute [rw] private_key
      attr_accessor :private_key

      # @!attribute [rw] public_key
      attr_accessor :public_key

      # initializer
      def initialize(config)
        keys_from_config config
        unless validate
          detect_ssh_keys_from_config
          unless validate
            detect_from_filesystem
            validate
          end
        end
      end

      def keys_from_config(config)
        @private_key = config.keys[:private] if key_is_set(config, :private)
        if key_is_set(config, :private)
          @public_key = config.keys[:public] if config.keys[:public]
        end
      end

      def key_is_set(config, name)
        config.keys[name].nil? && (config.keys[name] != UNSET_VALUE)
      end

      def empty?
        @private_key.nil? && @public_key.nil?
      end

      def private_key?
        !@private_key.nil?
      end

      def public_key?
        !@public_key.nil?
      end

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

      # used in detect_ssh_keys_from_filesystem
      def iterate_dir_fs(dir)
        Dir.entries(dir).each do |entry|
          entry = File.join(dir, entry)
          next unless good_file_on_filesystem?(entry)
          @private_key = private_filename_from_public(entry)
          @public_key = entry
          break
        end
      end

      # converts private SSH key to public
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

      # is a correct file in filesystem tobe a SSH key?
      def good_file_on_filesystem?(filename)
        File.file?(filename) && \
          File.extname(filename).eql?('.pub') && \
          File.exist?(private_filename_from_public(filename))
      end

      # gets paths for looking for SSH keys
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
