module Impressbox
  module Commands
    # Makebox command
    module Makebox
      # Commands definition
      class Command < Impressbox::Abstract::CommandHandler
        # Process command
        def process
          write_result_msg do_prepare
        end


      end
    end
  end
end
