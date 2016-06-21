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
        ::Impressbox::Objects::InstanceMaker.quick_instance(
          namespace,
          f
        )
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
