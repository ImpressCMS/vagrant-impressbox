module Impressbox
  # This module registers Vagrant actions
  module Action

    # Extending with Vagrant Buildin actions
    include Vagrant::Action::Builtin

    # Defining Machine Up action
    #
    #@return [::Vagrant::Action::Builder]
    def self.machine_up
      Vagrant::Action::Builder.new.tap do |builder|
        builder.use ::Impressbox::Actions::MachineUp
      end
    end

    # Defining Machine Destroy action
    #
    #@return [::Vagrant::Action::Builder]
    def self.machine_destroy
      Vagrant::Action::Builder.new.tap do |builder|
        builder.use ::Impressbox::Actions::MachineDestroy
      end
    end

  end
end
