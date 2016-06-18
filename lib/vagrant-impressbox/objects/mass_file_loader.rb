module Impressbox
  module Objects
    # Loads files from folder to execute action
    class MassFileLoader

      # Extends with Enumerable
      include Enumerable

      # Initializer
      #
      #@param namespace [String] What namespace to use for loaded files?
      #@param path      [Path]   From where to load files?
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

      # This is used to get next item
      def <<(val)
        @results_array << val
      end

      # This used for each iterating between results
      def each(&block)
        @results_array.each(&block)
      end

      private

      # Creates instance of class found in file
      #
      #@param namespace [String]  Namespace to use for founding a class
      #@param f         [String]  Filename
      #
      #@return [String]
      def quick_instance(namespace, f)
        cname = render_class_name_from_file(namespace, f)
        create_instance_from_class_name cname
      end

      # Gets class name from filename
      #
      #@param namespace [String]  Class namespace
      #@param file      [String]  Filename
      #
      #@return [String]
      def render_class_name_from_file(namespace, file)
        cnd = split_file_name(file).map do |s|
          s[0] = s[0, 1].upcase
          s
        end
        namespace + '::' + cnd.join('')
      end

      # Splits filename by _
      #
      #@param file [String] Filename to split
      #
      #@return [Array]
      def split_file_name(file)
        File.basename(file, '.rb').split('_')
      end

      # Create instance from class name
      #
      #@param class_name [String] Class name with namespace to create
      #
      #@return [Object]
      def create_instance_from_class_name(class_name)
        cname = class_name.split('::').inject(Object) do |o, c|
          o.const_get c
        end
        cname.new
      end

      # Is Ruby file?
      #
      #@param filename [String] Filename to check
      #
      #@return [Boolean]
      def ruby_file?(filename)
        return false if File.directory?(filename)
        File.extname(filename) == '.rb'
      end
    end
  end
end
