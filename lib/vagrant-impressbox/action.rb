module Impressbox
  module Action
    include Vagrant::Action::Builtin

    def self.machine_up
      Vagrant::Action::Builder.new.tap do |builder|
        builder.use ::Impressbox::Actions::MachineUp
      end
    end

    def self.machine_halt
      Vagrant::Action::Builder.new.tap do |builder|
        builder.use ::Impressbox::Actions::MachineHalt
      end
    end

    def self.machine_destroy
      Vagrant::Action::Builder.new.tap do |builder|
        builder.use ::Impressbox::Actions::MachineDestroy
      end
    end

  end
end
