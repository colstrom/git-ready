require 'contracts'
require 'terminal-announce'
require 'yaml'

require_relative 'interactive_setup/workspace'
require_relative 'interactive_setup/github_access_token'

module InteractiveSetup
  include Contracts

  Contract None => Any
  def self.start
    Announce.info 'Entering Interactive Setup (^c to exit)'
    settings = {}
    settings['workspace'] = Workspace.setup
    settings['github_access_token'] = GitHubAccessToken.setup
    save settings if valid? settings
    exit
  end

  Contract Hash => Bool
  def self.valid?(settings)
    if settings.value? nil
      Announce.failure 'Settings are not valid.'
      Announce.info "Settings were #{settings}"
      false
    else
      true
    end
  end

  Contract Hash => Any
  def self.save(settings)
    config_path = File.expand_path '~/.config'
    Dir.mkdir config_path unless Dir.exist? config_path
    File.write "#{config_path}/git-ready.yaml", YAML.dump(settings)
    Announce.success "Configuration saved to #{config_path}"
  end
end
