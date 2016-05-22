require_relative 'base_action'

module Impressbox
  module Actions
    # This is action to insert keys to remote machine when booting
    class InsertKey < BaseAction

      private

      def configure(machine, config)
        require_relative File.join('..', 'objects', 'ssh_key_detect.rb')
        keys = Impressbox::Objects::SshKeyDetect.new(config)

        insert_ssh_key_if_needed(
          machine,
          keys.public_key,
          keys.private_key
        )
      end

      def insert_ssh_key_if_needed(machine, public_key, private_key)
        machine.communicate.wait_for_ready 300

        machine_private_key machine.communicate, private_key
        machine_public_key machine.communicate, public_key
      end

      def machine_public_key(communicator, public_key)
        @ui.info I18n.t('ssh_key.updating.public')
        if machine_upload_file communicator, public_key, '~/.ssh/id_rsa.pub'
          communicator.execute 'touch ~/.ssh/authorized_keys'
          communicator.execute 'cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys'
          communicator.execute "echo `awk '!a[$0]++' ~/.ssh/authorized_keys` > ~/.ssh/authorized_keys"

          communicator.execute 'chmod 600 ~/.ssh/id_rsa.pub'
        end
      end

      def machine_private_key(communicator, private_key)
        @ui.info I18n.t('ssh_key.updating.private')
        if machine_upload_file communicator, private_key, '~/.ssh/id_rsa'
          communicator.execute 'chmod 400 ~/.ssh/id_rsa'
        end
      end

      def machine_upload_file(communicator, src_file, dst_file)
        if src_file.nil?
          @ui.info I18n.t('ssh_key.not_found')
          return false
        end
        communicator.execute 'chmod 777 ' + dst_file + ' || :'
        communicator.execute 'touch ' + dst_file
        communicator.execute 'truncate -s 0 ' + dst_file
        text = File.open(src_file).read
        text.gsub!(/\r\n?/, "\n")
        text.each_line do |line|
          communicator.execute "echo \"#{line.rstrip}\" >> #{dst_file}"
        end
        true
      end
    end
  end
end
