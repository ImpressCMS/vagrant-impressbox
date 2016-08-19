module Impressbox
  module Objects
    # Parses command line options
    class CommandOptionsParser

      # Extends with Enumerable
      include Enumerable

      # Creates ConfigData shortcut
      ConfigData = Impressbox::Objects::ConfigData

      # Default values
      #
      #@return [Hash]
      attr_reader :default_values

      # Linked command
      #
      #@return [Method]
      attr_reader :parse_options_method

      # Initializer
      #
      #@param banner [String] Banner
      #@param parent [Method] Used parse options method
      def initialize(banner, parse_options_method)
        @options = {}
        @default_values = read_default_values
        @parse_options_method = parse_options_method
        @parser = create_option_parser(banner)
      end

      # This is used to get next item
      def <<(val)
        @options << val
      end

      # This used for each iterating between results
      def each(&block)
        @options.each(&block)
      end

      # Gets all data
      #
      #@return [Hash]
      def all
        @options
      end

      # Gets item from config data
      #
      #@param key [String] Key to get item by it's name
      #
      #@return [Object]
      def [](key)
        @options[if key.is_a?(Symbol)
                   key
                 else
                   key.to_sym
                 end]
      end

      # Parse command line arguments
      def parse
        @parse_options_method.call @parser
      end

      private

      # Adds action for option
      #
      #@param o       [Object]      Option
      #@param short   [String,nil]  Short option variant
      #@param full    [String,nil]  Long option variant
      #@param desc    [String,nil]  Description
      #@param option  [String,nil]  Option name for options array
      def add_action_on(o, short, full, desc, option)
        if short
          o.on(short, full, desc) do |f|
            @options[option.to_sym] = f
          end
        else
          o.on(full, desc) do |f|
            @options[option.to_sym] = f
          end
        end
      end

      # Get all options from supplied yaml with this plugin
      #
      #@return [Hash]
      def options_cfg
        ConfigData.new('impressbox.yml').all
      end

      # Binds options to options array
      #
      #@param o [Object]  Option
      def bind_options(o)
        options_cfg.each do |option, data|
          short, full, desc = option_data_parse(data, option)
          add_action_on o, short, full, desc, option
        end
      end

      # Creates option parser
      #
      #@param banner      [String] Banner text
      #
      #@return [OptionParser]
      def create_option_parser(banner)
        OptionParser.new do |o|
          o.banner = banner
          o.separator ''

          bind_options o
        end
      end

      # Renders option description
      #
      #@param data   [Hash]   Sullied data
      #
      #@return [String]
      def option_description(data)
        I18n.t data[:description], @default_values
      end

      # Renders options from data
      #
      #@param data   [Hash]   Sullied data
      #@param option [String] Option name
      #
      #@return [Array]
      def option_data_parse(data, option)
        [
          option_short(data),
          option_full(option, data),
          option_description(data)
        ]
      end

      # Returns default values hash
      #
      #@return [Hash]
      def read_default_values
        require 'yaml'
        file = ConfigData.real_path('default.yml')
        ret = {}
        YAML.load(File.open(file)).each do |k, v|
          ret[k.to_sym] = v
        end
        ret[:templates] = templates.join(', ')
        ret[:repo_types] = repo_types.join(', ')
        ret
      end

      # Renders full option data
      #
      #@param option [String] Option name
      #@param data   [Hash]   Sullied data
      #
      #@return [String]
      def option_full(option, data)
        return data[:full] if data.key?(:full)
        d = option.downcase
        u = option.upcase
        "--#{d} #{u}"
      end

      # Renders short option
      #
      #@param data   [Hash]   Sullied data
      #
      #@return [String]
      def option_short(data)
        data[:short]
      end

      # Returns list of posssible templates
      #
      #@return [Array]
      def templates
        ConfigData.list_of_type 'templates'
      end

      # Returns list of posssible supported repository types
      #
      #@return [Array]
      def repo_types
        ::Impressbox::Command.all_repo_types
      end

    end
  end
end
