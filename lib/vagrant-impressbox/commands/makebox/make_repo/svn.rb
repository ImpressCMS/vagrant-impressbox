module Impressbox
  module Commands
    module Makebox
      module MakeRepo
        # Provisder for SVN make repo
        class Svn < Impressbox::Abstract::ExtMakeRepo

          # Execute
          def execute(repo_url)
            delete_files_if_exist ['.svn']
            `svn co #{repo_url} . --non-interactive`
            `svn add *`
            `svn commit -m "Initial commit (created with vagrant-impressbox)"`
            `svn update`
          end

          # Can be this repo type be executed?
          #
          #@return [Boolean]
          def available?
            ret = %x[ svn --version ]
            $?.success?
          end

        end
      end
    end
  end
end
