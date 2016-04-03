require 'vagrant'
require_relative File.join('objects', 'template')

# Impressbox
module Impressbox
  # Command class
  class Command < Vagrant.plugin('2', :command)
    DEFAULT_VALUES = {
      box: 'ImpressCMS/DevBox-Ubuntu',
      ip: '192.168.121.121',
      hostname: 'impresscms.dev',
      memory: 512,
      cpus: 1
    }.freeze

    OPTIONS = [
      {
        short: '-b',
        full: '--box BOX_NAME',
        description: "Box name for new box (default: #{DEFAULT_VALUES[:box]})",
        option: :box
      },
      {
        short: '-i',
        full: '--ip IP',
        description: "Defines IP (default: #{DEFAULT_VALUES[:ip]})",
        option: :ip
      },
      {
        short: '-u',
        full: '--url HOSTNAME',
        description: "Hostname associated with this box (default: #{DEFAULT_VALUES[:hostname]})",
        option: :hostname
      },
      {
        short: '-m',
        full: '--m RAM',
        description: "How much RAM (in megabytes)? (default: #{DEFAULT_VALUES[:memory]})",
        option: :memory
      },
      {
        short: '-c',
        full: '--c CPU_NUMBER',
        description: "How much CPU? (default: #{DEFAULT_VALUES[:cpus]})",
        option: :cpus
      }
    ].freeze

    def self.synopsis
      'Creates a Vagrantfile and config.yaml ready for use with ImpressBox'
    end

    def execute
      @options = DEFAULT_VALUES.dup
      argv = parse_options create_option_parser(@options)
      @options[:name] = make_name
      @template = Impressbox::Objects::Template.new
      unless argv.nil?
        @template.do_quick_prepare config_yaml_filename, @options
        @template.do_quick_prepare vagrantfile_filename, @options
        puts 'Vagrant enviroment created'
      end
      0
    end

    private

    def make_name
      @options[:hostname].gsub(/[^A-Za-z0-9_-]/, '-')
    end

    def make_config
      @template.prepare_file read_config_yaml, 'config.yaml', @options
    end

    def config_yaml_filename
      File.join @template.templates_path, 'config.yaml'
    end

    def vagrantfile_filename
      File.join @template.templates_path, 'Vagrantfile'
    end

    def create_option_parser(options)
      OptionParser.new do |o|
        o.banner = 'Usage: vagrant impressbox'
        o.separator ''

        OPTIONS.each do |option|
          o.on(option[:short], option[:full], option[:description]) do |f|
            options[option[:option]] = f
          end
        end
      end
    end
  end
end
