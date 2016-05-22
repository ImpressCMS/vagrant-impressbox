require 'mustache'

# Impressbox namespace
module Impressbox
  # Objects namespace
  module Objects
    # Template
    class Template
      def real_path(filename)
        File.join File.dirname(File.dirname(__FILE__)), 'templates', filename
      end

      def prepare_file(src_file, dst_file, options, default, base_file = nil)
        new_options = make_new_options(
          src_file, dst_file, options,
          default, base_file
        )
        ret = render_string(src_file, new_options)
        File.write dst_file, ret
        new_options.to_a == options.to_a
      end

      def render_string(src_file, options)
        Mustache.render File.read(src_file), options
      end

      def quick_prepare(filename, options, recreate, default, base_file = nil)
        dst_file = File.basename(filename)
        File.delete dst_file if recreate && File.exist?(dst_file)
        prepare_file filename, dst_file, options, default, base_file
      end

      private

      def make_new_options(_src_file, dst_file, options, default, base_file)
        merge_options_multiple(
          make_data_filenames_array([
                                      base_file,
                                      dst_file
                                    ]),
          default,
          options
        )
      end

      def make_data_filenames_array(filenames)
        filenames.reject do |f|
          f.nil? || f.empty?
        end
      end

      def merge_options_multiple(filenames, default, options)
        ret = default
        filenames.each do |filename|
          ret = merge_options(filename, ret.dup)
        end
        options.each do |key, val|
          next if key.to_s.start_with?('__')
          ret[key.to_sym] = val_first(val)
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
          next if key.to_s.start_with?('__')
          new_data[key.to_sym] = val_first(val)
        end
        new_data
      end

      def val_first(val)
        if val.is_a?(String)
          parts = val.split(/\r?\n/)
          val = parts if parts.length > 1
        end
        val
      end
    end
  end
end
