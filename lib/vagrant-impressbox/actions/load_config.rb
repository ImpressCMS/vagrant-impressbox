require_relative 'base_action'

module Impressbox
  module Actions
    # Configure from config
    class LoadConfig < BaseAction

      # Vagrantfile
      attr_reader :vagrantfile

      # Root path
      attr_reader :root_path

      def initialize(app, env)
        super app, env
        @vagrantfile = env[:env].vagrantfile.config
        @root_path = env[:env].root_path
        BaseAction.data[:enabled] = provision_enabled?
      end

      private

      def modify_config?
        true
      end

      def description
        I18n.t 'config.loading'
      end

      def configure(data)
        xaml_config
      end

      # Is ImpressBox provisioner enabled
      def provision_enabled?
        @vagrantfile.vm.provisioners.each do |provisioner|
          return true if provisioner.type == :impressbox
        end
        false
      end

      # load xaml config
      def xaml_config
        require_relative File.join('..', 'objects', 'config_file')
        file = detect_file
        @ui.info "\t" + I18n.t('config.loaded_from_file', file: file)
        Impressbox::Objects::ConfigFile.new file
      end

      def detect_file
        file = if good_file_in_config?(@vagrantfile.config.impressbox)
                 @vagrantfile.config.impressbox.file
               else
                 'config.yaml'
               end
        File.join @root_path, file
      end

      def good_file_in_config?(impressbox)
        return false if impressbox.nil?
        impressbox.file.is_a?(String)
      end
    end
  end
end
