module Impressbox
  # Keys handling class
  class Keys
    # variable for public key
    @public = nil

    # variable for private key
    @private = nil

    # create instance from config data
    def self.create_from_config(config)
      new(
        (config['keys']['private'] if config['keys'].key?('private')),
        (config['keys']['public'] if config['keys'].key?('public'))
      )
    end

    # Initializer
    def initialize(private_key = nil, public_key = nil)
      @public = public_key
      @private = private_key
    end

    # Are both variables empty?
    def empty?
      @private.nil? && @public.nil?
    end

    # Are both variables not filled?
    def filled?
      !@private.nil? && !@public.nil?
    end

    # prints variables contents to console
    def print
      print_key 'Public', @public
      print_key 'Private', @private
    end

    # print variable logic
    def print_key(name, value)
      if value.nil?
        print name + ' key was undetected'
      else
        print name + ' key autotected to ' + value.to_s + "\n"
      end
    end

    # makes some methods for this class private
    private :print_key
  end
end
