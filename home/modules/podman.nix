{ config, pkgs, lib, ... }:

{
  # Podman configuration for macOS
  home.file = lib.mkIf pkgs.stdenv.isDarwin {
    # Create launchd agent for podman socket
    "Library/LaunchAgents/io.podman.socket.plist" = {
      text = ''
        <?xml version="1.0" encoding="UTF-8"?>
        <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
        <plist version="1.0">
        <dict>
          <key>Label</key>
          <string>io.podman.socket</string>
          <key>ProgramArguments</key>
          <array>
            <string>${pkgs.podman}/bin/podman</string>
            <string>system</string>
            <string>service</string>
            <string>--time=0</string>
          </array>
          <key>RunAtLoad</key>
          <true/>
          <key>EnvironmentVariables</key>
          <dict>
            <key>PATH</key>
            <string>${pkgs.podman}/bin:/usr/bin:/bin:/usr/sbin:/sbin</string>
          </dict>
          <key>Sockets</key>
          <dict>
            <key>Listeners</key>
            <dict>
              <key>SockPathName</key>
              <string>${config.home.homeDirectory}/.local/share/containers/podman/machine/podman.sock</string>
            </dict>
          </dict>
        </dict>
        </plist>
      '';
      onChange = ''
        /bin/launchctl unload ~/Library/LaunchAgents/io.podman.socket.plist 2>/dev/null || true
        /bin/launchctl load ~/Library/LaunchAgents/io.podman.socket.plist
      '';
    };
  };

  # Environment variables for Podman
  home.sessionVariables = {
    DOCKER_HOST = "unix://${config.home.homeDirectory}/.local/share/containers/podman/machine/podman.sock";
    CONTAINERS_CONF = "${config.home.homeDirectory}/.config/containers/containers.conf";
    CONTAINERS_STORAGE_CONF = "${config.home.homeDirectory}/.config/containers/storage.conf";
  };

  # Create containers configuration
  xdg.configFile."containers/containers.conf".text = ''
    [engine]
    cgroup_manager = "cgroupfs"
    events_logger = "file"
    runtime = "${pkgs.podman}/bin/crun"
  '';

  # Create a wrapper script that ensures Podman Desktop finds podman
  home.packages = lib.mkIf pkgs.stdenv.isDarwin [
    (pkgs.writeShellScriptBin "podman-desktop-wrapped" ''
      export PATH="${pkgs.podman}/bin:$PATH"
      exec ${pkgs.podman-desktop}/bin/podman-desktop "$@"
    '')
  ];

  # Create an alias for convenience
  programs.zsh.shellAliases = lib.mkIf pkgs.stdenv.isDarwin {
    podman-desktop = "podman-desktop-wrapped";
  };
}