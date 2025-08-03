{ pkgs }:

{
  # Default system configuration
  # Override these in system-specific files
  username = builtins.getEnv "USER";
  homeDirectory = builtins.getEnv "HOME";

  # You can also use platform-specific logic
  homeDirectoryPrefix = if pkgs.stdenv.isDarwin then "/Users" else "/home";
}
