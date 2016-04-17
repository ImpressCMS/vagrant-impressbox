module Impressbox
  module Actions
    # This is action to insert keys to remote machine when booting
    class InsertKey
      def initialize(app, env)
        @app = app
        @ui = env[:ui]
      end

      def call(env)
        @app.call env
        @machine = env[:machine]
        insert_ssh_key_if_needed(
          Impressbox::Plugin.get_item(:public_key),
          Impressbox::Plugin.get_item(:private_key)
        )
      end

      private

      def insert_ssh_key_if_needed(public_key, private_key)
        @machine.communicate.wait_for_ready 300

        machine_private_key @machine.communicate, private_key
        machine_public_key @machine.communicate, public_key
      end

      def machine_public_key(communicator, public_key)
        @ui.info I18n.t('ssh_key.updating.public')
        machine_upload_file communicator, public_key, '~/.ssh/id_rsa.pub'
        communicator.execute 'touch ~/.ssh/authorized_keys'
        communicator.execute 'cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys'
        communicator.execute "echo `awk '!a[$0]++' ~/.ssh/authorized_keys` > ~/.ssh/authorized_keys"

        communicator.execute 'chmod 600 ~/.ssh/id_rsa.pub'
      end

      def machine_private_key(communicator, private_key)
        @ui.info I18n.t('ssh_key.updating.private')
        machine_upload_file communicator, private_key, '~/.ssh/id_rsa'
        communicator.execute 'chmod 400 ~/.ssh/id_rsa'
      end

      def machine_upload_file(communicator, src_file, dst_file)
        communicator.execute 'chmod 777 ' + dst_file + ' || :'
        communicator.execute 'touch ' + dst_file
        communicator.execute 'truncate -s 0 ' + dst_file
        text = File.open(src_file).read
        text.gsub!(/\r\n?/, "\n")
        text.each_line do |line|
          communicator.execute "echo \"#{line.rstrip}\" >> #{dst_file}"
        end
      end
    end
  end
end
