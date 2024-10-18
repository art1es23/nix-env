{ pkgs, config, inputs, ... }: {
  environment.shells = [ pkgs.bash pkgs.zsh ];
  environment.loginShell = pkgs.zsh;

  # Allow to install unfree apps as like Obsidian
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search by name, run:
  # $ nix-env -qaP | grep wget
  environment.systemPackages = with pkgs; [ 
        mkalias
        ripgrep
        fzf
        direnv
        bat
        zoxide
        eza
        thefuck
        fd
        git
        lazygit
        lazydocker
        alacritty
        starship
        neovim
        tmux
        obsidian
        wezterm
        # inputs.wezterm.packages.${pkgs.system}.default
    ];

  homebrew = {
      enable = true;
      brews = [
        "mas"
        "imagemagick"
      ];
      casks = [
        "hammerspoon"
        "iina"
        "the-unarchiver"
        # "firefox"
        # "google-chrome"
        # "notion"
        # "binance"
        # "spotify"
        # "microsoft-teams"
        # "figma"
        # "discord"
        # "nordpass"
        # "1password"
      ];
      masApps = {
        # "Yoink" = 457622435;
      };
      onActivation.cleanup = "zap";
      onActivation.upgrade = true;
      onActivation.autoUpdate = true;
    };

  # font-meslo-lg-nerd-font
  fonts.packages = 
    [
      (pkgs.nerdfonts.override { fonts = [ "JetBrainsMono" "Meslo" "FiraCode"]; })
    ];


  system.activationScripts.applications.text = let
    env = pkgs.buildEnv {
      name = "system-applications";
      paths = config.environment.systemPackages;
      pathsToLink = "/Applications";
    };
  in
    pkgs.lib.mkForce ''
      # Set up applications.
      echo "setting up /Applications..." >&2
      rm -rf /Applications/Nix\ Apps
      mkdir -p /Applications/Nix\ Apps
      find ${env}/Applications -maxdepth 1 -type l -exec readlink '{}' + |
      while read src; do
        app_name=$(basename "$src")
        echo "copying $src" >&2
        ${pkgs.mkalias}/bin/mkalias "$src" "/Applications/Nix Apps/$app_name"
      done
    '';

  system.defaults = {
    NSGlobalDomain.AppleInterfaceStyle = "Dark";
    NSGlobalDomain.AppleWindowTabbingMode = "fullscreen";
    NSGlobalDomain.NSWindowShouldDragOnGesture = true;

    dock.autohide = true;
    dock.tilesize = 54;
    dock.magnification = true;
    dock.largesize = 75;
    dock.mru-spaces = false;
    dock.show-process-indicators = true;
    dock.enable-spring-load-actions-on-all-items = true;
    dock.mouse-over-hilite-stack = true;

    # WindowManager.GloballyEnabled = true;
    # WindowManager.AutoHide = true;
    WindowManager.EnableStandardClickToShowDesktop = false;
    WindowManager.StandardHideDesktopIcons = true;
    WindowManager.StandardHideWidgets = true;
    # WindowManager.StageManagerHideWidgets = true;

    finder.AppleShowAllExtensions = true;
    finder.FXPreferredViewStyle = "clmv";
    finder._FXSortFoldersFirst = true;
    finder.ShowPathbar = true;

    magicmouse.MouseButtonMode = "OneButton";
    trackpad.TrackpadThreeFingerDrag = true;

    menuExtraClock.Show24Hour = true;

    loginwindow.LoginwindowText = "qmpwwsd <code>";
    screencapture.location = "~/Pictures/screenshots";
    screensaver.askForPasswordDelay = 10;
  };

  # Auto upgrade nix package and the daemon service.
  services.nix-daemon.enable = true;
  # nix.package = pkgs.nix;

  # Necessary for using flakes on this system.
  nix.settings.experimental-features = "nix-command flakes";

  # Create /etc/zshrc that loads the nix-darwin environment.
  programs.zsh.enable = true;  # default shell on catalina
  # programs.fish.enable = true;

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 5;

  # The platform the configuration will be used on.
  nixpkgs.hostPlatform = "aarch64-darwin";

  # Allow to use TouchID
  security.pam.enableSudoTouchIdAuth = true;
}
