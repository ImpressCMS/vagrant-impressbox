require 'vagrant'
require_relative File.join('objects', 'template')
require_relative File.join('objects', 'config_data')

# Impressbox
module Impressbox
  # Command class
  class Command < Vagrant.plugin('2', :command)

    # Config.yaml file
    #
    #@return [String]
    attr_reader :file

    # Config.yaml data path
    #
    #@return [String]
    attr_reader :cwd

    # Parsed arguments
    #
    #@return [::Impressbox::Objects::CommandOptionsParser]
    attr_reader :args

    # Creates ConfigData shortcut
    ConfigData = Impressbox::Objects::ConfigData

    # Creates Template shortcut
    Template = Impressbox::Objects::Template

    # Creates CommandOptionsParser shortcut
    CommandOptionsParser = Impressbox::Objects::CommandOptionsParser

    # Initializer
    #
    #@param argv  [Objects] Arguments
    #@param env   [Env]     Enviroment
    def initialize(argv, env)
      return if env.nil?
      super argv, env
      @file = selected_yaml_file
      @cwd = env.cwd.to_s
      @template = Template.new
      @args = CommandOptionsParser.new(
        banner,
        method(:parse_options)
      )
    end

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
      c_args = @args.parse
      unless c_args.nil?
        write_result_msg do_prepare
      end
      0
    end

    # Gets all supported repo types that can be created
    #
    #@return [Array]
    def self.all_repo_types
      ret = Array.new
      instance = self.new(nil, nil)
      methods = instance.private_methods(false)
      methods.grep(/make_repo/).each do |item|
        ret.push item[10..-1]
      end
      ret
    end

    private

    # Gets yaml file from current vagrantfile
    #
    #@return [String]
    def selected_yaml_file
      p = current_impressbox_provisioner
      if p.nil? || p.config.nil? || p.config.file.nil? ||
        !(p.config.file.is_a?(String) && p.config.file.chop.length > 0)
        return 'config.yaml'
      end
      p.config.file
    end

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

    # Prepares options array
    #
    #@param options [Hash]  Current options
    def update_latest_options(options)
      options[:info] = {
        last_update: Time.now.to_s,
        website_url: 'http://impresscms.org'
      }
      options[:file] = @file.dup
      update_name options
    end

    # Updates name param in options hash
    #
    #@param options [Hash]  Input/output hash
    def update_name(options)
      if options.key?(:name) && options[:name].is_a?(String) && options[:name].length > 0
        return
      end
      hostname = if options.key?(:hostname) then
                   options[:hostname]
                 else
                   @args.default_values[:hostname]
                 end
      hostname = hostname[0] if hostname.is_a?(Array)
      options[:name] = hostname.gsub(/[^A-Za-z0-9_-]/, '-')
    end

    # Writes message for action result
    #
    #@param result [Boolean]
    def write_result_msg(result)
      msg = if result then
              I18n.t 'config.recreated'
            else
              I18n.t 'config.updated'
            end
      @env.ui.info msg
    end

    # Runs prepare all actions
    def do_prepare
      quick_make_file @file, 'config.yaml'
      quick_make_file 'Vagrantfile', 'Vagrantfile'
      must_recreate
      create_repo
    end

    # Renders and safes file
    #
    #@param local_file [String] Local filename
    #@param tpl_file  [String] Template filename
    def quick_make_file(local_file, tpl_file)
      current_file = local_file(local_file)
      template_file = @template.real_path(tpl_file)
      @template.make_file(
        template_file,
        current_file,
        @args.all.dup,
        make_data_files_array(current_file),
        method(:update_latest_options)
      )
    end

    # Makes data files array
    #
    #@param current_file [String] Current file name
    #
    #@return [Array]
    def make_data_files_array(current_file)
      data_files = [
        ConfigData.real_path('default.yml')
      ]
      unless use_template_filename.nil?
        data_files.push use_template_filename
      end
      unless must_recreate
        data_files.push current_file
      end
      data_files
    end

    # Gets local file name with path
    #
    #@param file [String] File to append path
    #
    #@return [String]
    def local_file(file)
      File.join @cwd, file
    end

    # Returns template filename if specific template was specified (not default)
    #
    #@return [String,nil]
    def use_template_filename
      return nil unless @args[:___use_template___]
      ConfigData.real_type_filename 'templates', @args[:___use_template___]
    end

    # Must recreate config files ?
    #
    #@return [Boolean]
    def must_recreate
      @args[:___recreate___]
    end

    # Creates repo for project if needed
    def create_repo
      return if @args[:___create_repo___].empty?
      Command.all_repo_types.each do |dir|
        next unless File.exist?(dir)
        FileUtils.rm_rf(dir)
      end
      url = @args[:___create_repo___].strip
      type = detect_repo_type(url)
      if type.nil?
        puts I18n.t 'command.impressbox.error.cant_detect_repo_type'
        return
      end
      method("make_repo_" + type).call url
    end

    # Detects repo type from file scheme uri
    #
    #@param url [String] Url from where to detect type
    #
    #@return [String,nil]
    def detect_repo_type(url)
      Command.all_repo_types.each do |possible_type|
        next unless string_contains_uppercase_or_lowercase(url, possible_type)
        return possible_type
      end
      nil
    end

    # Delete files and dirs if exist
    #
    #@param files [Array] What to delete?
    def delete_files_if_exist(files)
      require 'fileutils'
      files.each do |file|
        next unless File.exist?(file)
        FileUtils.rm_rf file
      end
    end

    # Makes SVN repo
    #
    #@param url [String] Url of the repo
    def make_repo_svn(url)
      delete_files_if_exist ['.svn']
      `svn co #{url} . --non-interactive`
      `svn add *`
      `svn commit -m "Initial commit (created with vagrant-impressbox)"`
      `svn update`
    end

    # Makes GIT repo
    #
    #@param url [String] Url of the repo
    def make_repo_git(url)
      delete_files_if_exist ['.git', '.gitignore']
      `git init`
      `git add .`
      `git commit -m "Initial commit (created with vagrant-impressbox)"`
      `git remote add origin #{url}`
      `git push -u origin --all`
    end

    # Makes Mercurial repo
    #
    #@param url [String] Url of the repo
    def make_repo_mercurial(url)
      delete_files_if_exist ['.hg']
      `hg init`
      `hg add`
      `hg commit -m 'Initial commit (created with vagrant-impressbox)'`
      `hg push #{url}`
    end

    # Shortcut for mercurial repo
    #
    #@param url [String] Url of the repo
    def make_repo_hg(url)
      make_repo_mercurial url
    end

    # Checks if string contains lowercase version of another string
    # or atleast uppercase version
    #
    #@param str     [String]  String where to look for another string
    #@param search  [String]  String to search for
    #
    #@return [Boolean]
    def string_contains_uppercase_or_lowercase(str, search)
      str.include?(search.downcase) or str.include?(search.upcase)
    end

    # Returns command banner (aka Usage)
    #
    #@return [String]
    def banner
      I18n.t 'command.impressbox.usage', cmd: 'vagrant impressbox'
    end

  end
end
