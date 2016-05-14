module Impressbox
  # Defines builder for actions
  module ActionBuilder
    include Vagrant::Action::Builtin

    def self.insert_key
      require_relative File.join('actions', 'insert_key')
      Vagrant::Action::Builder.new.tap do |builder|
        builder.use Impressbox::Actions::InsertKey
      end
    end

    def self.copy_git_settings
      require_relative File.join('actions', 'copy_git_settings')
      Vagrant::Action::Builder.new.tap do |builder|
        builder.use Impressbox::Actions::CopyGitSettings
      end
    end

    def self.load_config
      require_relative File.join('actions', 'load_config')
      Vagrant::Action::Builder.new.tap do |builder|
        builder.use Impressbox::Actions::LoadConfig
      end
    end
  end
end
