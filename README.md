[![Gem](https://img.shields.io/gem/dtv/vagrant-impressbox.svg)](https://rubygems.org/gems/vagrant-impressbox) [![Gem](https://img.shields.io/gem/v/vagrant-impressbox.svg)](https://rubygems.org/gems/vagrant-impressbox) [![license](https://img.shields.io/github/license/ImpressCMS/vagrant-impressbox.svg?maxAge=2592000)](License.txt) [![Inline docs](http://inch-ci.org/github/ImpressCMS/vagrant-impressbox.svg?branch=master)](http://inch-ci.org/github/ImpressCMS/vagrant-impressbox) [![codebeat badge](https://codebeat.co/badges/5249954f-b39b-4750-bfa9-3c7fd5edbeb1)](https://codebeat.co/projects/github-com-impresscms-vagrant-impressbox-master)


# ImpressBox

*NOTE:* this readme is for 0.2 version. Please wait for the release!

**ImpressBox** is plugin to make easier to configure web development virtual enviroment for [Vagrant](https://www.vagrantup.com). It comes with some predefined templates for some frameworks and CMS'es (latest versions):
  - [CakePHP](http://cakephp.org)
  - [ImpressCMS](http://impresscms.org)
  - [Laravel](http://laravel.com)
  - [NodeJS](http://nodejs.org)
  - [Ruby On Rails](http://rubyonrails.org)
  - [Symfony](http://symfony.com)
  - [Wordpress](http://wordpress.org)
  - [Yii](http://www.yiiframework.com)
  - [Zend Framework](http://framework.zend.com)
  - [Joomla](http://joomla.org)
  - [Django](https://www.djangoproject.com)

## Installation

Run below command from your command line:

    vagrant plugin install vagrant-impressbox

## Usage

To use Impressbox plugin, you can run `vagrant impressbox` command from command line. It will create required configuration files. Also it's possible to use some options to modify default configuration files creation behavior:

    vagrant impressbox [options]

      -b, --box=BOX_NAME               Box name for new box
          --ip=IP                      Defines IP
          --url=HOSTNAME               Hostname associated with this box
          --memory=RAM                 How much RAM (in megabytes)?
          --cpus=CPU_NUMBER            How much CPU?
      -r, --recreate                   Recreates config instead of updating (so you don't need to delete first)
      -t, --template=NAME              This argument says that predefined config will be used when creating box.
      -h, --help                       Print this help
      
For example if you want to create new a project based on [ImpressCMS](http://impresscms.org), you must execute this command:

    vagrant impressbox -t impresscms -r
    
Also such command would work in this case too:

    vagrant impressbox -r
  
For [Laravel](https://laravel.com) such command is needed:

    vagrant impressbox -t laravel -r
    
And so on.

## Development & Contributing

If you want to try add something to this plugin, you need before starting do these things:
 * Clone this repository
 * Open command line in cloned directory
 * Run `bundle`
 
If you want to your changes, you can run `bundle exec vagrant impressbox` command (also here is possible to use some commands options).

Bug reports and pull requests are welcome [on GitHub](https://github.com/ImpressCMS/impressbox).
