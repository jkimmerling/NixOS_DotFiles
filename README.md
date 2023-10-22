# NixOS_DotFiles
My ever changing NixOS configuration


## Install

If you want to run the NixOS setup I have created:

* Install any of the NixOS versions (GUI or CLI)
* Create your `daily driver` user (if this was not the user you created on intall)
* Switch to that user
* Clone the repo into your home directory
* Change into the directory - `cd NixOS_DotFiles`
* Make the setup script exectuable - `chmod +x setup.sh`
* Run the `setup.sh` script with these provided args
  * `./setup.sh -u <username> -c <channel>`
    * `<username>` is your user name
    * `<channel>` is the NixOS channel you want to use. 
      * Empty = the default channel in the script
      * Unstable = the unstable branch
      * The exact channel = the exact channel you want to use
* Reboot