require 'mustache'

# Impressbox namespace
module Impressbox
  # Objects namespace
  module Objects
    # Template
    class Template
      def path
        File.join File.dirname(File.dirname(__FILE__)), 'templates'
      end

      def prepare_file(src_filename, dst_filename, options, base_filename = nil)
        new_options = merge_options_multiple(
          make_data_filenames_array([
            base_filename,
            dst_filename
          ]),
          options
        )     
        ret = render_string(src_filename, new_options)
        File.write dst_filename, ret
        new_options.to_a == options.to_a
      end

      def render_string(src_filename, options)
        Mustache.render File.read(src_filename), options
      end

      def do_quick_prepare(filename, options, recreate, base_filename = nil)
        dst_filename = File.basename(filename)
        File.delete dst_filename if recreate && File.exist?(dst_filename)        
        prepare_file filename, dst_filename, options, base_filename
      end

      private      
      
      def make_data_filenames_array(filenames)
        filenames.reject do |f|
           f.nil? or f.empty?
        end
      end
      
      def merge_options_multiple(filenames, options)
        ret = options
        filenames.each do |filename|
          ret = merge_options(filename, ret.dup)
        end
        ret
      end

      def merge_options(filename, options)
        return options unless File.exist? filename
        ext = File.extname(filename)
        return options if ext.nil? || ext == ''
        method_name = 'merge_file' + ext.sub!('.', '_')
        method(method_name).call filename, options
      end
      
      def merge_file_yml(filename, options)
        merge_file_yaml(filename, options)
      end

      def merge_file_yaml(filename, options)
        old_data = YAML.load(File.open(filename))
        new_data = options.dup
        old_data.each do |key, val|
          new_data[key.to_sym] = val
        end
        new_data
      end
    end
  end
end
