require 'mustache'

# Impressbox namespace
module Impressbox
  # Objects namespace
  module Objects
    # Extended Mustache template engine with some usefull functions
    class MustacheExt < Mustache

      # Execute command on host and return result
      #
      #@param value [String] Command to execute
      #
      #@return [String]
      def host_cmd(value)
        `#{value}`
      end

      # Show input field with message
      #
      #@param value [String] Message for input field
      #
      #@return [String]
      def input(value)
        print value
        ret = STDIN.gets.chomp
        unless ret
          raise I18n.t('template.error.imput_empty')
        end
        ret
      end

      # Gets enviroment variable
      #
      #@param value [String] Enviroment variable name
      #
      #@return [String]
      def env(value)
        return "" unless ENV.key?(value)
        ENV[value].to_s
      end

      # Displays input field if no env
      #
      #@param value [String] Enviroment variable name + input string
      #
      #@return [String]
      def input_if_no_env(value)
        env_name, text = value.split(':', 2)
        ret = env(env_name)
        unless ret.length > 0
          ret = input(text)
        end
        ret
      end
      
      # Gets host os
      #
      #@return [String]
      def host_os
        Vagrant::Util::Platform.platform
      end
      
    end
  end
end
