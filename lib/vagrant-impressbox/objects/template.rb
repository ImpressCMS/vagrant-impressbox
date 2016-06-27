require 'mustache'

# Impressbox namespace
module Impressbox
  # Objects namespace
  module Objects
    # Template engine based on Mustache
    class Template

      # Templates dir constant
      #
      #@return [String]
      TEMPLATES_DIR = File.join(File.dirname(__dir__), 'templates').freeze

      # Alternative extensions
      #
      #@return [Hash]
      ALT_EXTENSIONS = {
        :yml => 'yaml'
      }.freeze

      # Gets real path for filename
      #
      #@param filename [String] Filename
      #
      #@return [String]
      def real_path(filename)
        File.join TEMPLATES_DIR, filename
      end

      # Extract options from files
      #
      #@param files [Array] Files where to search for options
      #
      #@return [Hash]
      def read_options(files)
        ret = {}
        files.each do |file|
          data = read_file(file)
          next if data.nil? || data.empty?
          ret = merge_hashes(ret, data)
        end
        ret
      end

      # Makes options hash
      #
      #@param options [Hash]   Key values data
      #@param files   [Array]  Data files to be used for parsing
      #
      #@return [Hash]
      def make_options(options, files = [])
        merge_hashes(
          if files.empty?
            {}
          else
            read_options(files)
          end,
          options
        )
      end

      # Renders filename and saves
      #
      #@param tpl_file          [String]  Template filename
      #@param dst_file          [String]  Where to save rendered result
      #@param options           [Hash]    Key values data
      #@param data_files        [Array]   Data files to be used for parsing
      #@param options_processor [Method]  Options processor method *used when modifing params at end)
      def make_file(tpl_file, dst_file, options, data_files = [], options_processor = nil)
        all_options = make_options(options, data_files)
        options_processor.call(all_options) unless options_processor.nil?
        data = render_file(tpl_file, all_options)
        File.write dst_file, data
      end

      # Renders filename to string
      #
      #@param src_file [String] Template filename
      #@param options  [Hash]   Key values data
      #
      #@return [String]
      def render_file(src_file, options)
        o = {}
        options.each do |key, value|
          if value.is_a?(String)
            if value.lines.length > 1
              o[key] = value.lines.map do |line|
                line.gsub /[\n]+$/, ''
              end
            else
              o[key] = value
            end
          else
            o[key] = value
          end
        end
        Mustache.render File.read(src_file), o
      end

      private

      # Merge two hashes
      #
      #@param a [Hash] Hash 1
      #@param b [Hash] Hash 2
      #
      #@return [Hash]
      def merge_hashes(a, b)
        ret = a.dup
        b.each do |key, value|
          if value.is_a?(Hash) && ret.key?(key)
            ret[key.to_sym] = merge_hashes(ret[key.to_sym], value)
          else
            ret[key.to_sym] = value
          end
        end
        ret
      end

      # Reads file to Hash
      #
      #@param filename [String] File to read
      #
      #@return [nil,Hash]
      def read_file(filename)
        ext = real_extension(filename)
        method_name = 'read_' + ext
        begin
          return method(method_name).call(filename)
        rescue StandardError => e
          return nil
        end
      end

      # Gets normal extension from filename
      #
      #@param filename [String] Filename from wehere to get read goo extension
      #
      #@return [String]
      def real_extension(filename)
        ext = File.extname(filename)
        return ext if ext.empty?
        ext = ext[1, ext.length - 1].sub('.', '_').downcase
        e_s = ext.to_sym
        return ext unless ALT_EXTENSIONS.key?(e_s)
        ALT_EXTENSIONS[e_s].dup
      end

      # Read .yaml extension
      #
      #@param filename [String]  Data source filename
      #
      #@return [Hash]
      def read_yaml(filename)
        require 'yaml'
        YAML.load File.open(filename)
      end
    end
  end
end
