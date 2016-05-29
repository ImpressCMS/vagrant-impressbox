module Impressbox
  module Objects
    # Loads files from folder to execute action
    class MassFileLoader

      include Enumerable

      def initialize(namespace, path)
        @results_array = []
        path = File.expand_path(path, __dir__)
        Dir.entries(path).select do |f|
          fname = File.expand_path(f, path)
          next unless ruby_file?(fname)
          require fname
          @results_array.push quick_instance(namespace, f)
        end
      end

      def <<(val)
        @results_array << val
      end

      def each(&block)
        @results_array.each(&block)
      end

      private

      def quick_instance(namespace, f)
        cname = render_class_name_from_file(namespace, f)
        create_instance_from_class_name cname
      end

      def render_class_name_from_file(namespace, file)
        cnd = split_file_name(file).map do |s|
          s[0] = s[0, 1].upcase
          s
        end
        namespace + '::' + cnd.join('')
      end

      def split_file_name(file)
        File.basename(file, '.rb').split('_')
      end

      def create_instance_from_class_name(class_name)
        puts class_name
        class_name.split('::').inject(Object) do |o, c|
          o.const_get c
        end
      end

      def ruby_file?(filename)
        return false if File.directory?(filename)
        File.extname(filename) == '.rb'
      end
    end
  end
end
