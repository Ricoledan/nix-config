{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.programs.sketchybar;

  sketchybarConfig = ''
    #!/bin/bash

    # SketchyBar Config

    # Bar Settings
    sketchybar --bar height=32 \
                     blur_radius=30 \
                     position=top \
                     sticky=off \
                     padding_left=10 \
                     padding_right=10 \
                     color=0x15ffffff

    # Default values for all items
    sketchybar --default icon.font="Hack Nerd Font:Bold:17.0" \
                         icon.color=0xffffffff \
                         label.font="Hack Nerd Font:Bold:14.0" \
                         label.color=0xffffffff \
                         padding_left=5 \
                         padding_right=5 \
                         label.padding_left=4 \
                         label.padding_right=4 \
                         icon.padding_left=4 \
                         icon.padding_right=4

    # Left Items
    sketchybar --add item space_separator left \
               --set space_separator icon= \
                                     icon.color=0xffffffff \
                                     padding_left=10 \
                                     padding_right=10 \
                                     label.drawing=off

    # Center Items (Clock)
    sketchybar --add item clock center \
               --set clock update_freq=10 \
                           icon=  \
                           script="$PLUGIN_DIR/clock.sh"

    # Right Items
    sketchybar --add item battery right \
               --set battery script="$PLUGIN_DIR/battery.sh" \
                             update_freq=120 \
               --subscribe battery system_woke power_source_change

    sketchybar --add item cpu right \
               --set cpu script="$PLUGIN_DIR/cpu.sh" \
                         update_freq=2

    sketchybar --add item memory right \
               --set memory script="$PLUGIN_DIR/memory.sh" \
                            update_freq=5

    # Finalize
    sketchybar --update
  '';

  clockPlugin = ''
    #!/bin/bash
    sketchybar --set $NAME label="$(date '+%a %d %b %I:%M %p')"
  '';

  batteryPlugin = ''
    #!/bin/bash
    PERCENTAGE=$(pmset -g batt | grep -Eo "\d+%" | cut -d% -f1)
    CHARGING=$(pmset -g batt | grep 'AC Power')

    if [ $PERCENTAGE = "" ]; then
      exit 0
    fi

    if [ $PERCENTAGE -gt 80 ]; then
      ICON=
    elif [ $PERCENTAGE -gt 60 ]; then
      ICON=
    elif [ $PERCENTAGE -gt 40 ]; then
      ICON=
    elif [ $PERCENTAGE -gt 20 ]; then
      ICON=
    else
      ICON=
    fi

    if [[ $CHARGING != "" ]]; then
      ICON=
    fi

    sketchybar --set $NAME icon="$ICON" label="''${PERCENTAGE}%"
  '';

  cpuPlugin = ''
    #!/bin/bash
    CPU=$(top -l 2 | grep -E "^CPU" | tail -1 | awk '{print $3 + $5}')
    sketchybar --set $NAME label="''${CPU}%"
  '';

  memoryPlugin = ''
    #!/bin/bash
    MEMORY=$(memory_pressure | grep "System-wide memory free percentage:" | awk '{print 100-$5}')
    sketchybar --set $NAME label="''${MEMORY}%"
  '';

in
{
  options.programs.sketchybar = {
    enable = mkEnableOption "SketchyBar macOS status bar";

    package = mkOption {
      type = types.package;
      default = pkgs.sketchybar;
      description = "The SketchyBar package to use";
    };

    config = mkOption {
      type = types.str;
      default = sketchybarConfig;
      description = "SketchyBar configuration script";
    };

    plugins = mkOption {
      type = types.attrsOf types.str;
      default = {
        "clock.sh" = clockPlugin;
        "battery.sh" = batteryPlugin;
        "cpu.sh" = cpuPlugin;
        "memory.sh" = memoryPlugin;
      };
      description = "SketchyBar plugin scripts";
    };

    extraConfig = mkOption {
      type = types.lines;
      default = "";
      description = "Extra configuration to append to sketchybarrc";
    };
  };

  config = mkIf cfg.enable {
    home.packages = [ cfg.package pkgs.hack-font ];

    xdg.configFile = {
      "sketchybar/sketchybarrc" = {
        text = ''
          ${cfg.config}
          ${cfg.extraConfig}
        '';
        executable = true;
      };
    } // lib.mapAttrs'
      (name: content: {
        name = "sketchybar/plugins/${name}";
        value = {
          text = content;
          executable = true;
        };
      })
      cfg.plugins;

    launchd.agents.sketchybar = {
      enable = true;
      config = {
        ProgramArguments = [ "${cfg.package}/bin/sketchybar" ];
        RunAtLoad = true;
        KeepAlive = true;
        ProcessType = "Interactive";
        Nice = -20;
      };
    };
  };
}
