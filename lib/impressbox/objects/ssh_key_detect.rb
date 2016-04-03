# To change this license header, choose License Headers in Project Properties.
# To change this template file, choose Tools | Templates
# and open the template in the editor.

module Impressbox
  module Objects
    class SshKeyDetect
      # @!attribute [rw] private_key
      attr_accessor :private_key

      # @!attribute [rw] public_key
      attr_accessor :public_key

      # initializer
      def initialize(config)
        keys_from_config config if config.key?('keys')
        unless validate
          detect_ssh_keys_from_config
          unless validate
            detect_from_filesystem
            validate
          end
        end
      end

      def keys_from_config(config)
        if config['keys'].key?('private')
          @private_key = config['keys']['private']
        end
        @public_key = config['keys']['public'] if config['keys'].key?('public')
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
        return false if !private_key? || !public_key?
        File.exist?(@private_key) && File.exist?(@public_key)
      end

      # Try detect SSH keys by using only a config
      def detect_ssh_keys_from_config
        ret = Key.create_from_config(@_config)

        return ret if ret.empty? || ret.filled?

        if private_defined
          ret.public = ret.private + '.pub'
          return ret
        end

        ret.private = private_filename_from_public(ret.private)
        ret
      end

      # Try detect SSH keys by using local filestystem
      def detect_ssh_keys_from_filesystem
        @ssh_keys_search_paths.each do |dir|
          keys = iterate_dir_fs(dir)
          return keys unless keys.empty?
        end
        Keys.new
      end

      # used in detect_ssh_keys_from_filesystem
      def iterate_dir_fs(dir)
        Dir.entries(dir).each do |entry|
          entry = File.join(dir, entry)
          next unless good_file_on_filesystem?(entry)
          return Keys.new(
            private_filename_from_public(entry),
            entry
          )
        end
        Keys.new
      end

      # converts private SSH key to public
      def private_filename_from_public(filename)
        File.join(
          File.dirname(
            filename,
            File.basename(
              filename,
              '.pub'
            )
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
