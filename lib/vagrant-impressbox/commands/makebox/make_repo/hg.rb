module Impressbox
  module Commands
    module Makebox
      module MakeRepo
        # Provisder for Mercurial make repo
        class Hg < Impressbox::Abstract::ExtMakeRepo

          # Execute
          def execute(repo_url)
            delete_files_if_exist ['.hg']
            `hg init`
            `hg add`
            `hg commit -m 'Initial commit (created with vagrant-impressbox)'`
            `hg push #{repo_url}`
          end

          # Can be this repo type be executed?
          #
          #@return [Boolean]
          def available?
            ret = %x[ hg --version ]
            $?.success?
          end

          # Gets aliases for repo types
          #
          #@return [Array]
          def aliases
            [
              'Mercurial'
            ]
          end

        end
      end
    end
  end
end
