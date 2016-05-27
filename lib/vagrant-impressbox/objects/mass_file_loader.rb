module Impressbox::Objects
  # Loads files from folder to execute action
  class MassFileLoader < Array

    def new(namespace, path)
      super
      Dir.entries(path).select do |f|
        next unless rubyFile?(f)
        self.push createInstanceFromClassName(
          renderClassNameFromFile(namespace, f)
        )
      end
    end

    private

    def renderClassNameFromFile(namespace, file)
      classNameData = File.basename(file, '.rb').split('_').map do |s|
        s[0,1].upcase
      end
      namespace + '::' + classNameData.join('')
    end

    def createInstanceFromClassName(className)
      return className.split('::').inject(Object) do |o, c|
        o.const_get c
      end
    end

    def rubyFile?(filename)
      return false if File.directory?(f)
      File.extname(filename) == '.rb'
    end

  end
end
