# Impressbox namespace
module Impressbox
  # Objects namespace
  module Objects
    # Template
    class Template
      def templates_path
        File.join File.dirname(File.dirname(__FILE__)), 'templates'
      end

      def prepare_file(src_filename, dst_filename, options)
        ret = render_string(src_filename, options)
        File.write dst_filename, ret
      end

      def render_string(src_filename, options)
        ret = File.read(src_filename)
        options.each do |key, value|
          ret = ret.gsub('%' + key.to_s + '%', value.to_s)
        end
        ret
      end

      def do_quick_prepare(filename, options)
        prepare_file filename, File.basename(filename), options
      end
    end
  end
end
