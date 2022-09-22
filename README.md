# NixOS_DotFiles
My ever changing NixOS configuration


## Install

* Install any of the NixOS versions (GUI or CLI)
* Clone the repo into your home directory
* Run the `setup.sh` script with these provided args
  * `./setup.sh -u <username> -c <channel>`
    * `<username>` is your user name
    * `<channel>` is the NixOS channel you want to use. 
      * Empty = the default channel in the script
      * Unstable = the unstable branch
      * The exact channel = the exact channel you want to use
* Reboot