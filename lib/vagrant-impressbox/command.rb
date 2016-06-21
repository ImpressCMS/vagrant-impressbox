require 'vagrant'
require_relative File.join('objects', 'template')
require_relative File.join('objects', 'config_data')

# Impressbox
module Impressbox
  # Command class
  class Command < Vagrant.plugin('2', :command)

    # Creates ConfigData shortcut
    ConfigData = Impressbox::Objects::ConfigData

    # Gets command description
    #
    #@return [String]
    def self.synopsis
      I18n.t 'command.impressbox.synopsis'
    end

    # Execute command
    #
    #@return [Integer]
    def execute
      prepare_options
      @template = Impressbox::Objects::Template.new
      write_result_msg do_prepare unless argv.nil?
      0
    end

    private

    # Get default values
    #
    #@return [Hash]
    def default_values
      data = ConfigData.new('default.yml').all
      data[:templates] = ConfigData.list_of_type('for').join(', ')
      data
    end

    # Get all options from supplied yaml with this plugin
    #
    #@return [Hash]
    def options_cfg
      ConfigData.new('command.yml').all
    end

    # Prepares options array
    def prepare_options
      @options = {}
      # default_values
      @options[:name] = make_name
      @options[:info] = {
        last_update: Time.now.to_s,
        website_url: 'http://impresscms.org'
      }
    end

    # Parses and returns arguments options
    def argv
      parse_options create_option_parser
    end

    # Writes message for action result
    #
    #@param result [Boolean]
    def write_result_msg(result)
      if result
        puts I18n.t('config.recreated')
      else
        puts I18n.t('config.updated')
      end
    end

    # Runs prepare all actions
    def do_prepare
      do_prepare_vagrantfile
      do_prepare_congig_yaml
    end

    # Prepare config2.yaml
    def do_prepare_congig_yaml
      @template.quick_prepare(
        config_yaml_filename,
        @options,
        must_recreate,
        default_values,
        use_template_filename
      )
    end

    # Prepare VagrantFile
    def do_prepare_vagrantfile
      @template.quick_prepare(
        vagrantfile_filename,
        @options,
        must_recreate,
        default_values,
        use_template_filename
      )
    end

    # Returns template filename if specific template was specified (not default)
    #
    #@return [String,nil]
    def use_template_filename
      return nil unless @options[:___use_template___]
      ConfigData.real_type_filename 'for', @options[:___use_template___]
    end

    # Must recreate config files ?
    #
    #@return [Boolean]
    def must_recreate
      @options[:___recreate___]
    end

    # Makes name
    #
    #@return [String]
    def make_name
      if @options[:hostname]
        return @options[:hostname].gsub(/[^A-Za-z0-9_-]/, '-')
      end
      default_values[:hostname].gsub(/[^A-Za-z0-9_-]/, '-')
    end

    def make_config
      @template.prepare_file read_config_yaml, 'config2.yaml', @options, ""
    end

    # Gets Config.yaml full filename
    #
    #@return [String]
    def config_yaml_filename
      @template.real_path 'config2.yaml'
    end

    # Gets Vagrantfile full filename
    #
    #@return [String]
    def vagrantfile_filename
      @template.real_path 'Vagrantfile'
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

    # Renders option description
    #
    #@param data   [Hash]   Sullied data
    #
    #@return [String]
    def option_description(data)
      I18n.t data[:description], default_values
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

    # Returns command banner (aka Usage)
    #
    #@return [String]
    def banner
      I18n.t 'command.impressbox.usage', cmd: 'vagrant impressbox'
    end

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
    #@return [OptionParser]
    def create_option_parser
      OptionParser.new do |o|
        o.banner = banner
        o.separator ''

        bind_options o
      end
    end
  end
end
