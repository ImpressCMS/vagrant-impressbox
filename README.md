[![Gem](https://img.shields.io/gem/dtv/vagrant-impressbox.svg)](https://rubygems.org/gems/vagrant-impressbox) [![Gem](https://img.shields.io/gem/v/vagrant-impressbox.svg)](https://rubygems.org/gems/vagrant-impressbox) [![license](https://img.shields.io/github/license/ImpressCMS/vagrant-impressbox.svg?maxAge=2592000)](License.txt) 

# ImpressBox

**ImpressBox** is plugin to make easier to configure web development virtual enviroment for [Vagrant](https://www.vagrantup.com). It comes with some predefined templates for some popular frameworks and CMS'es (latest versions):
  - [CakePHP](//cakephp.org)
  - [ImpressCMS](//impresscms.org)
  - [Laravel](https://laravel.com)
  - [NodeJS](https://nodejs.org)
  - [Ruby On Rails](http://rubyonrails.org)
  - [Symfony](https://symfony.com)
  - [Wordpress](https://wordpress.org)
  - [Yii](http://www.yiiframework.com)
  - [Zend Framework](https://framework.zend.com)

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
