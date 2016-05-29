module Impressbox
  module Objects
    # Loads files from folder to execute action
    class MassFileLoader < Array
      def new(namespace, path)
        super
        Dir.entries(path).select do |f|
          next unless ruby_file?(f)
          push create_instance_from_class_name(
                 render_class_name_from_file(namespace, f)
               )
        end
      end

      private

      def render_class_name_from_file(namespace, file)
        cnd = split_file_name(file).map do |s|
          s[0, 1].upcase
        end
        namespace + '::' + cnd.join('')
      end

      def split_file_name(file)
        File.basename(file, '.rb').split('_')
      end

      def create_instance_from_class_name(class_name)
        class_name.split('::').inject(Object) do |o, c|
          o.const_get c
        end
      end

      def ruby_file?(filename)
        return false if File.directory?(f)
        File.extname(filename) == '.rb'
      end
    end
  end
end
