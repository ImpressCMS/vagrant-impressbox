source 'http://rubygems.org'

ENV['TEST_VAGRANT_VERSION'] ||= 'v1.9.4'

group :plugins do
  gem 'vagrant-impressbox', path: '.'
  gem 'vagrant-hostmanager', '~> 1.8', '>= 1.8.1'
end

group :test do
  if ENV['TEST_VAGRANT_VERSION'] == 'HEAD'
    gem 'vagrant', github: 'mitchellh/vagrant', branch: 'master'
  else
    gem 'vagrant', github: 'mitchellh/vagrant', tag: ENV['TEST_VAGRANT_VERSION']
  end
end

eval_gemfile "#{__FILE__}.local" if File.exist? "#{__FILE__}.local"
