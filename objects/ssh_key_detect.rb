module Impressbox
  module Objects
    # SSH key detect
    class SSHkeyDetect < Impressbox::Objects::Base
      # Keys
      @_keys = nil

      # Binded config
      @_config = nil

      # Quick way for detect
      def self.detect(config)
        instance = new(config)
        instance.keys
      end

      # initializer
      def initialize(config)
        @_keys = Keys.new
        @_config = config
        try_config if @_config.key?('keys')
        try_filesystem unless @_keys.empty?
      end

      def keys
        @_keys
      end

      # try config data and validates result
      def try_config
        return unless @_config.key?('keys')
        @_keys = @detect_ssh_keys_from_config
        err_msg = validate_from_config ssh_keys
        error err_msg unless err_msg.nil?
      end

      # try filesystem detection and validates result
      def try_filesystem
        @_keys = @detect_ssh_keys_from_filesystem
        if @_keys.empty?
          error "Can't autodetect SSH keys. Please specify in config.yaml."
        end
        @_keys.print
      end

      # validates data from config
      def validate_from_config(keys)
        return nil if keys.empty?
        unless keys['private'].nil? || (!File.exist? keys['private'])
          return "Private key defined in config.yaml can't be found."
        end
        unless File.exist? keys['public']
          return "Public key defined in config.yaml can't be found."
        end
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

      # Makes some methods private
      private :detect_ssh_keys_from_config,
              :detect_ssh_keys_from_filesystem,
              :try_config,
              :try_filesystem,
              :validate_from_config,
              :iterate_dir_fs,
              :good_file_on_filesystem?,
              :private_filename_from_public
    end
  end
end
