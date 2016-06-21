# Impressbox namespace
module Impressbox
  # Objects namepsace
  module Objects
    # This class is used when dealing with extensions
    class Extensions
      # Disable creation with new for this class
      # Making new method private
      private_class_method :new

      # Creates instance of extension
      #
      #@param name [String] Extension name
      #
      #@return [::Impressbox::Abstract::Extension]
      def self.create_instance(name)
        ::Impressbox::Objects::InstanceMaker.quick_instance(
          'Impressbox::Extensions',
          self.filename(name)
        )
      end

      # Sanitize extension name
      #
      #@param name [String] Extension name to sanitize
      #
      #@return [String]
      def self.sanitize_name(name)
        name.downcase
      end

      # Check if extension specified
      #
      #@param name [String] Extension name
      #
      #@return [Boolean]
      def self.specified?(name)
        name.nil?
      end

      # Check if extension exists
      #
      #@param name [String] Extension name
      #
      #@return [Boolean]
      def self.exist?(name)
        File.exist? self.filename(name)
      end

      # Check if extension value is good
      #
      #@param name [String] Extension name
      #
      #@return [Boolean]
      def self.good?(name)
        return true unless self.specified?(name)
        self.exist? name
      end

      protected

      # Gets full filename by extension name
      #
      #@param ext_name [String] Extension name
      #
      #@return [nil,String]
      def self.filename(ext_name)
        return nil if ext_name == nil
        ext = self.sanitize_name(name) + ".rb"
        File.join __dir__, '..', 'extensions', ext
      end

    end
  end
end

