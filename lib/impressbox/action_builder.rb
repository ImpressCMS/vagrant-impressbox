module Impressbox
  module ActionBuilder
    
    include Vagrant::Action::Builtin

    def self.insert_key
      require_relative File.join("actions", "insert_key")
      Vagrant::Action::Builder.new.tap do |builder|        
        builder.use Impressbox::Actions::InsertKey
      end
    end
  end
end
