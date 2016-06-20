# Impressbox namespace
module Impressbox
  # Objects namepsace
  module Abstract
    # This class used for defining an extension if some extra functionality is needed
    class Extension

      # Libraries path
      #
      #@return [String]
      LIBRARIES_PATH = File.join(__dir__, 'ext_libs').freeze

      protected

      # Require library (downloads if needed from url)
      #
      #@param name  [String]  Library name
      #@param url   [String]  From where download library
      def require_library(name, url)
        dst_path = File.join(LIBRARIES_PATH, name)
        unless File.exist?(dst_path)
          download_from_git url, dst_path
        end
      end

      # Require file from library
      #
      #@param library_name  [String] Library name from where to require file
      #@param file          [String] File with possible path to require
      def require_file(library_name, file)
        require File.join(
          LIBRARIES_PATH,
          library_name,
          file
        )
      end

      private

      # Downloads library from GIT
      #
      #@param url       [String]  From where to download
      #@param dst_path  [String]  Destination path
      def download_from_git(url, dst_path)
        old_path = Dir.pwd
        unless File.exist?(dst_path)
          Dir.mkdir LIBRARIES_PATH
        end
        Dir.chdir LIBRARIES_PATH
        system 'git clone ' + url + ' ' + dst_path
        Dir.chdir old_path
      end

    end
  end
end
