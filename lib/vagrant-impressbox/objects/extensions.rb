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
        filename = self.ext_filename(name)
        require filename
        ::Impressbox::Objects::InstanceMaker.quick_instance(
          'Impressbox::Extensions',
          filename
        )
      end

      # Check if extension specified
      #
      #@param name [String] Extension name
      #
      #@return [Boolean]
      def self.specified?(name)
        name.nil? || (name.to_s.strip.length > 0)
      end

      # Check if extension exists
      #
      #@param name [String] Extension name
      #
      #@return [Boolean]
      def self.exist?(name)
        File.exist? self.ext_filename(name)
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
      def self.ext_filename(ext_name)
        return nil if ext_name == nil
        ext = ext_name.downcase.gsub(/[^a-z0-9_]/, '_') + ".rb"
        concated = File.join(__dir__, '..', 'extensions', ext)
        File.expand_path concated
      end

    end
  end
end

