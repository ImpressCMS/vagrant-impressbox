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

      def prepare_file(src_filename, dst_filename, options)
        new_options = merge_options(dst_filename, options)
        ret = render_string(src_filename, new_options)
        File.write dst_filename, ret
        new_options.to_a == options.to_a
      end

      def render_string(src_filename, options)
        Mustache.render File.read(src_filename), options
      end

      def do_quick_prepare(filename, options, recreate)
        dst_filename = File.basename(filename)
        File.delete dst_filename if recreate && File.exist?(dst_filename)
        prepare_file filename, dst_filename, options
      end

      private

      def merge_options(filename, options)
        return options unless File.exist? filename
        ext = File.extname(filename)
        return options if ext.nil? || ext == ''
        method_name = 'merge_file' + ext.sub!('.', '_')
        method(method_name).call filename, options
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
