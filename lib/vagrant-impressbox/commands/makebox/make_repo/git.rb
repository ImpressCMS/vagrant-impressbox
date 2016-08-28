module Impressbox
  module Commands
    module Makebox
      module MakeRepo
        # Provisder for GIT make repo
        class Git < Impressbox::Abstract::ExtMakeRepo

          # Execute
          def execute(repo_url)
            delete_files_if_exist ['.git', '.gitignore']
            `git init`
            `git add .`
            `git commit -m "Initial commit (created with vagrant-impressbox)"`
            `git remote add origin #{repo_url}`
            `git push -u origin --all`
          end

          # Can be this repo type be executed?
          #
          #@return [Boolean]
          def available?
            ret = %x[ git --version ]
            $?.success?
          end

        end
      end
    end
  end
end
