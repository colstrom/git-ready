require 'contracts'
require 'highline/import'
require 'terminal-announce'

module InteractiveSetup
  module Workspace
    def self.setup
      path = ask 'Enter the path to your workspace.'
      actual_path = File.expand_path path
      Announce.warning "No path given, assuming #{actual_path}" if path.empty?
      if Dir.exist? actual_path
        actual_path
      else
        Announce.failure 'Directory does not exist.'
        setup
      end
    end
  end
end
