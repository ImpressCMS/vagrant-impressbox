require 'vagrant'
require_relative File.join('objects', 'template')
require_relative File.join('objects', 'config_data')

# Impressbox
module Impressbox
  # Command class
  class Command < Vagrant.plugin('2', :command)
    ConfigData = Impressbox::Objects::ConfigData

    def self.synopsis
      I18n.t 'command.impressbox.synopsis'
    end

    def execute
      prepare_options
      @template = Impressbox::Objects::Template.new
      write_result_msg do_prepare unless argv.nil?
      0
    end

    private

    def default_values
      data = ConfigData.new('default.yml').all
      data[:templates] = ConfigData.list_of_type('for').join(', ')
      data
    end

    def options_cfg
      Impressbox::Objects::ConfigData.new('command.yml').all
    end

    def prepare_options
      @options = {}
      # default_values
      @options[:name] = make_name
      @options[:info] = {
        last_update: Time.now.to_s,
        website_url: 'http://impresscms.org'
      }
    end

    def argv
      parse_options create_option_parser(@options)
    end

    def write_result_msg(result)
      if result
        puts I18n.t('config.recreated')
      else
        puts I18n.t('config.updated')
      end
    end

    def do_prepare
      @template.do_quick_prepare(
        vagrantfile_filename,
        @options,
        must_recreate,
        default_values,
        use_template_filename
      )
      @template.do_quick_prepare(
        config_yaml_filename,
        @options,
        must_recreate,
        default_values,
        use_template_filename
      )
    end

    def use_template_filename
      return nil unless @options[:___use_template___]
      ConfigData.real_type_filename('for', @options[:___use_template___])
    end

    def must_recreate
      @options[:___recreate___]
    end

    def make_name
      if @options[:hostname]
        return @options[:hostname].gsub(/[^A-Za-z0-9_-]/, '-')
      else
        return default_values[:hostname].gsub(/[^A-Za-z0-9_-]/, '-')
      end
    end

    def make_config
      @template.prepare_file read_config_yaml, 'config.yaml', @options
    end

    def config_yaml_filename
      File.join @template.path, 'config.yaml'
    end

    def vagrantfile_filename
      File.join @template.path, 'Vagrantfile'
    end

    def option_full(option, data)
      return data[:full] if data.key?(:full)
      d = option.downcase
      u = option.upcase
      "--#{d} #{u}"
    end

    def option_short(data)
      data[:short]
    end

    def option_description(data)
      I18n.t data[:description], default_values
    end

    def option_data_parse(data, option)
      [
        option_short(data),
        option_full(option, data),
        option_description(data)
      ]
    end

    def create_option_parser(_options)
      OptionParser.new do |o|
        o.banner = I18n.t('command.impressbox.usage', cmd: 'vagrant impressbox')
        o.separator ''

        options_cfg.each do |option, data|
          short, full, desc = option_data_parse(data, option)
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
      end
    end
  end
end
