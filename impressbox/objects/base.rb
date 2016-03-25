module Impressbox
  module Objects
    # here goes all functions that can be triggered
    # for any delivered class
    class Base
      def error(msg)
        raise ::Vagrant::Errors::VagrantError.new, "#{msg}\n"
      end
    end
  end
end
