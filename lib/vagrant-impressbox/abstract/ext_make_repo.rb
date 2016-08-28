module Impressbox
  module Abstract
    # Make repo base
    class ExtMakeRepo

      # Gets name
      def name
        self.class.name.split('::').last.downcase
      end

      # Execute
      def execute(repo_url)
        raise I18n.t('configuring.error.must_overwrite')
      end

      # Can be this repo type be executed?
      #
      #@return [Boolean]
      def available?
        raise I18n.t('configuring.error.must_overwrite')
      end

      # Gets aliases for repo types
      #
      #@return [Array]
      def aliases
        []
      end

      protected

      # Delete files and dirs if exist
      #
      #@param files [Array] What to delete?
      def delete_files_if_exist(files)
        require 'fileutils'
        files.each do |file|
          next unless File.exist?(file)
          FileUtils.rm_rf file
        end
      end

    end
  end
end
