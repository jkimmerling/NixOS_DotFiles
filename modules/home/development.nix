{ config, pkgs, ... }:

{
  # ===== DEVELOPMENT CONFIGURATION =====

  home.packages = with pkgs; [
    # Development Tools
    git
    neovim
    tmux
    nodejs_24

    # Programming Languages
    beam.packages.erlang_28.elixir_1_18
    beam.packages.erlang_28.erlang
  ];

  # Git configuration
  programs.git = {
    enable = true;
    userName = "jasonk";
    userEmail = "jkimmerling@protonmail.com";
    extraConfig = {
      push = {
        autoSetupRemote = true;  # Automatically set upstream when pushing new branches
      };
      branch = {
        autoSetupMerge = "always";  # Automatically set up tracking for new branches
      };
    };
  };

  # VS Code configuration
  programs.vscode = {
    enable = true;
    profiles.default.extensions = with pkgs.vscode-extensions; [
      # Python
      ms-python.python

      # C/C++
      ms-vscode.cpptools

      # Elixir
      elixir-lsp.vscode-elixir-ls
      phoenixframework.phoenix

      # Nix
      arrterian.nix-env-selector
      jnoortheen.nix-ide
      bbenoist.nix

      # DevOps
      ms-azuretools.vscode-docker
      redhat.vscode-yaml
      ms-vscode-remote.remote-ssh

      # Editor enhancements
      jdinhlife.gruvbox
      yzhang.markdown-all-in-one
    ];
  };

  # Enable direnv for automatic environment loading
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  # Keep Firefox links on the current workspace while reusing the existing profile
  programs.firefox = {
    enable = true;
    profiles."jason-main" = {
      path = "3n2y12vq.default";
      isDefault = true;
      extraConfig = ''
        user_pref("widget.disable-workspace-management", true);
      '';
    };
  };
}
