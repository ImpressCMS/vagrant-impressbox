# coding: utf-8
$LOAD_PATH << File.expand_path(File.join(File.dirname(__FILE__), 'lib'))
require 'impressbox/version'

Gem::Specification.new do |spec|
  spec.name          = 'impressbox'
  spec.version       = Impressbox::VERSION
  spec.authors       = ["Raimondas Rimkevi\xC4\x8Dius"]
  spec.email         = ['mekdrop@impresscms.org']

  spec.summary       = <<-EOD
    This plugin can do provision and create configurations for simple boxes for development
  EOD
  spec.description = <<-EOD
    This plugin can do provision and create configurations for simple boxes for development
  EOD
  spec.homepage      = 'http://impresscms.org'
  spec.license       = 'MIT'

  spec.files = `git ls-files -z`.split("\0")
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_path = 'lib'

  spec.add_development_dependency 'bundler', '<= 1.10.5'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 2.14.0'
  spec.add_development_dependency 'vagrant-pristine', '~> 0.3.0'

  spec.add_dependency 'mustache', '~> 1.0'
  spec.add_dependency 'vagrant-hostmanager', '~> 1.8', '>= 1.8.1'
  spec.add_dependency 'vagrant-exec', '~> 0.5.2'
end
