require 'vagrant'

module Impressbox
  module Abstract
    # This is a base to use for command handlers
    class CommandHandler < Vagrant.plugin('2', :command)

      # Data path
      #
      #@return [String]
      attr_reader :cwd

      # Parsed arguments
      #
      #@return [::Impressbox::Objects::CommandOptionsParser]
      attr_reader :args

      # Creates ConfigData shortcut
      ConfigData = Impressbox::Objects::ConfigData

      # Creates CommandOptionsParser shortcut
      CommandOptionsParser = Impressbox::Objects::CommandOptionsParser

      # Creates InstanceMaker shorcut
      InstanceMaker = Impressbox::Objects::InstanceMaker

      # Initializer
      #
      #@param argv  [Objects] Arguments
      #@param env   [Env]     Enviroment
      def initialize(argv, env)
        return if env.nil?
        super argv, env
        @cwd = env.cwd.to_s
        @args = CommandOptionsParser.new(
          banner,
          method(:parse_options)
        )
      end

      # Gets command description
      #
      #@return [String]
      def self.synopsis
        I18n.t 'command.'+self.invoke_name+'.synopsis'
      end

      # Gets name to invoke this command
      #
      #@return [String]
      def self.invoke_name
        self.class.name.split('::').last.downcase
      end

      # Execute command
      #
      #@return [Integer]
      def execute
        c_args = @args.parse
        unless c_args.nil?
          invoke_special_args c_args, :configure
          process
          invoke_special_args c_args, :execute
        end
        0
      end

      # Process command
      def process

      end

      protected

      # Gets current provisioner with impressbox type
      #
      #@return [::VagrantPlugins::Kernel_V2::VagrantConfigProvisioner,nil]
      def current_impressbox_provisioner
        @env.vagrantfile.config.vm.provisioners.each do |provisioner|
          next unless provisioner.type == :impressbox
          return provisioner
        end
        nil
      end

      # Write info
      #
      #@param msg [String]
      def info(msg)
        @env.ui.info msg
      end

      private

      # Returns command banner (aka Usage)
      #
      #@return [String]
      def banner
        I18n.t 'command.'+self.invoke_name+'.usage', cmd: 'vagrant ' + self.invoke_name
      end

      # Invoke special args
      #
      #@param args    [Hash]    Command line args to process
      #@param method  [String]  Method name to invoke
      def invoke_special_args(args, method)
        args.each do |arg, value|
          name = arg.to_s
          next unless name.start_with?('___')
          cname = get_class_name_for_special_arg(name)
          instance = InstanceMaker.create_instance_from_class_name(cname)
          instance.method(method.to_s).call value
        end
      end

      # Get class name for special arg
      #
      #@param arg [String] Argument name to make into class name
      #
      #@return [String]
      def get_class_name_for_special_arg(arg)
        ret = arg.sub('___', '').split('_').map do |part|
          part.capitalize
        end
        '::Impressbox::SpecialArgs::' + ret.join('')
      end

    end
  end
end
