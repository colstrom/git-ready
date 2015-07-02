require 'contracts'
require 'settingslogic'
require 'terminal-announce'

require_relative 'interactive_setup'

# Singleton for loading configs from common paths.
class Settings < Settingslogic
  include InteractiveSetup

  config_paths = %w(/etc /usr/local/etc ~/.config .)

  config_paths.each do |config_path|
    config_file = File.expand_path "#{ config_path }/git-ready.yaml"
    source config_file if File.exist? config_file
  end

  load!
rescue Errno::ENOENT
  Announce.warning "Unable to find a configuration in #{config_paths}"
  InteractiveSetup.start
end
