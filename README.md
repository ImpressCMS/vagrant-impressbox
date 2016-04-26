[![Gem](https://img.shields.io/gem/dtv/vagrant-impressbox.svg)]() [![Gem](https://img.shields.io/gem/v/vagrant-impressbox.svg)]() [![license](https://img.shields.io/github/license/ImpressCMS/vagrant-impressbox.svg?maxAge=2592000)](License.txt) 

# ImpressBox

ImpressBox is plugin to make easier to configure virtual enviroment for Vagrant. 

## Installation

Run below command from your command line:
`vagrant plugin install vagrant-impressbox`

## Usage

To use Impressbox plugin, you can run `vagrant impressbox` command from command line. It will create required configuration files. Also it's possible to use some options to modify default configuration files creation behavior:

    vagrant impressbox [options]

      -b, --box=BOX_NAME               Box name for new box (default: ImpressCMS/DevBox-Ubuntu)
          --ip=IP                      Defines IP (default: )
          --url=HOSTNAME               Hostname associated with this box (default: impresscms.dev)
          --memory=RAM                 How much RAM (in megabytes)? (default: 512)
          --cpus=CPU_NUMBER            How much CPU? (default: 1)
      -r, --recreate                   Recreates config instead of updating (so you don't need to delete first)
      -f, --for=NAME                   This argument says that predefined config will be used when creating box. Possible names: impresscms
      
      -h, --help                       Print this help

## Development

If you want to try add something to this plugin, you need before starting do these things:
 * Clone this repository
 * Open command line in cloned directory
 * Run `bundle install`
 
If you want to your changes, you can run `bundle exec vagrant impressbox` command (also here is possible to use some commands options).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/ImpressCMS/impressbox.
