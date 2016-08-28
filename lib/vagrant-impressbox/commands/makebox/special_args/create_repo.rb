module Impressbox
  module Commands
    module Makebox
      module SpecialArgs
        # Create repo argument
        class CreateRepo < Impressbox::Abstract::CommandSpecialArg

          MassFileLoader = Impressbox::Objects::MassFileLoader

          def configure(value)

          end

          def execute(value)

          end

          # Gets all supported repo types that can be created
          #
          #@return [Array]
          def self.all_repo_types
            ret = []
            Impressbox::Objects::MassFileLoader.new(
              'Impressbox::Commands::Makebox::MakeRepo',
              File.join(__dir__, '..', 'make_repo')
            ).each do |item|
              next unless item.available?
              ret.push item.name
            end
            ret
          end

          protected

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

          private

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

        end
      end
    end
  end
end
