# Impressbox namespace
module Impressbox
  # Objects namespace
  module Objects
    # Class for dealing when trying fast to create instances
    class InstanceMaker
      # Disable creation with new for this class
      # Making new method private
      private_class_method :new

      # Creates instance of class found in file
      #
      #@param namespace [String]  Namespace to use for founding a class
      #@param f         [String]  Filename
      #
      #@return [String]
      def self.quick_instance(namespace, f)
        cname = self.render_class_name_from_file(namespace, f)
        self.create_instance_from_class_name cname
      end

      # Gets class name from filename
      #
      #@param namespace [String]  Class namespace
      #@param file      [String]  Filename
      #
      #@return [String]
      def self.render_class_name_from_file(namespace, file)
        cnd = self.split_file_name(file).map do |s|
          s[0] = s[0, 1].upcase
          s
        end
        namespace + '::' + cnd.join('')
      end

      # Create instance from class name
      #
      #@param class_name [String] Class name with namespace to create
      #
      #@return [Object]
      def self.create_instance_from_class_name(class_name)
        cname = class_name.split('::').inject(Object) do |o, c|
          o.const_get c
        end
        cname.new
      end

      protected

      # Splits filename by _
      #
      #@param file [String] Filename to split
      #
      #@return [Array]
      def self.split_file_name(file)
        File.basename(file, '.rb').split('_')
      end
    end
  end
end

