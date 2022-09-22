# NixOS_DotFiles
My ever changing NixOS configuration


## Install

* Install any of the NixOS versions (GUI or CLI)
* Clone the repo into your home directory
* Change the username in the `configuration.nix` file to whatever your you creted in your NixOS install
* Run the `setup.sh` script with these provided args
  * `./setup.sh <username> <channel>`
    * `<username>` is your user name
    * `<channel>` is the NixOS channel you want to use. 
      * Empty = the default channel in the script
      * Unstable = the unstable branch
      * The exact channel = the exact channel you want to use
* Run `sudo nixos-rebuild switch`
* Reboot