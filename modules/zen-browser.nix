{ config, pkgs, lib, inputs, ... }:

{
  # ===== ZEN BROWSER WITH CAELESTIA THEME =====

  # NOTE: You will need to:
  # 1. Launch Zen Browser once to create your profile
  # 2. Find your profile directory in ~/.zen/
  # 3. Update the profile path below (replace "xxxxxx.default" with your actual profile)
  # 4. Install the CaelestiaFox extension from: https://addons.mozilla.org/en-US/firefox/addon/caelestiafox

  # Enable userChrome.css loading in Zen Browser
  home.file.".zen/yjo5uxfs.Default Profile/user.js".text = ''
    // Enable loading of userChrome.css
    user_pref("toolkit.legacyUserProfileCustomizations.stylesheets", true);
  '';

  # Create userChrome.css for Zen Browser theming
  home.file.".zen/yjo5uxfs.Default Profile/chrome/userChrome.css".text = builtins.readFile (
    pkgs.fetchurl {
      url = "https://raw.githubusercontent.com/caelestia-dots/caelestia/main/zen/userChrome.css";
      sha256 = "0isnfp3l1d98gjhvzd0clzqb45sici5139h0fiidhas196nyklrn";
    }
  );

  # Create native messaging host manifest for CaelestiaFox extension
  home.file.".mozilla/native-messaging-hosts/caelestiafox.json".text = builtins.toJSON {
    name = "caelestiafox";
    description = "Native app for CaelestiaFox extension.";
    path = "${config.home.homeDirectory}/.local/lib/caelestia/caelestiafox";
    type = "stdio";
    allowed_extensions = [ "caelestiafox@caelestia.org" ];
  };

  # Install the Fish native app script
  home.file.".local/lib/caelestia/caelestiafox" = {
    text = ''
      #!/usr/bin/env fish

      function message -a msg
          # The message length as 4 hex bytes
          set -l x (printf '%08X' (string length -- $msg))
          # Write each of the 4 bytes
          printf '%b' "\\x$(string sub -s 7 -l 2 $x)\\x$(string sub -s 5 -l 2 $x)\\x$(string sub -s 3 -l 2 $x)\\x$(string sub -s 1 -l 2 $x)"
          # Write the message itself
          printf '%s' $msg
      end

      set -q XDG_STATE_HOME && set -l state $XDG_STATE_HOME || set -l state $HOME/.local/state
      set -l state_dir $state/caelestia
      set -l scheme_path $state_dir/scheme.json

      message (jq -c . $scheme_path)

      inotifywait -q -e 'close_write,moved_to,create' -m $state_dir | while read dir events file
          test "$dir$file" = $scheme_path && message (jq -c . $scheme_path)
      end
    '';
    executable = true;
  };

  # Install Zen Browser and required dependencies for the native app
  home.packages = with pkgs; [
    inputs.zen-browser.packages.${pkgs.system}.default
    jq
    inotify-tools
  ];
}
