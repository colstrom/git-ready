require 'contracts'
require 'highline/import'
require 'octokit'
require 'terminal-announce'
require 'yaml'

module InteractiveSetup
  include Contracts

  Contract nil => Any
  def self.start
    Announce.info 'Entering Interactive Setup (^c to exit)'
    settings = {}
    settings['workspace'] = Workspace.setup
    settings['github_access_token'] = GitHubAccessToken.setup
    save settings if validate settings
    exit
  end

  def self.validate(settings)
    if settings.value? nil
      Announce.failure 'Settings are not valid.'
      Announce.info "Settings were #{settings}"
      false
    else
      true
    end
  end

  def self.save(settings)
    config_path = File.expand_path('~/.config/git-ready.yaml')
    File.write config_path, YAML.dump(settings)
    Announce.success "Configuration saved to #{config_path}"
  end

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

  module GitHubAccessToken
    def self.setup
      Announce.info 'If you leave this blank, git-ready will do most of the work for you. As a fallback, you can generate your own at https://github.com/settings/tokens/new'
      token = ask 'Enter your GitHub Personal Access Token:', String
      token = guided_generation[:token] if token.empty?
      token if works? token
    end

    def self.guided_generation
      login = ask 'Enter your GitHub login:'
      password = ask('Enter your GitHub password:') { |c| c.echo = '*' }
      generate login, password
    rescue Octokit::OneTimePasswordRequired
      Announce.info 'Your account has 2-Factor Authentication enabled. Awesome!'
      headers = { 'X-GitHub-OTP' => ask('Enter a valid 2-Factor Auth Token') }
      generate login, password, headers
    end

    def self.generate(login, password, headers = {}, first_attempt = true)
      github = Octokit::Client.new login: login, password: password
      github.create_authorization(note: 'git-ready',
                                  scopes: ['repo'],
                                  headers: headers)
    rescue Octokit::Unauthorized
      Announce.failure 'Invalid Credentials'
    rescue Octokit::UnprocessableEntity
      if first_attempt
        Announce.warning 'Found an old token. Replacing it.'
        delete_existing_authorization github, headers
        generate login, password, headers, false
      else
        Announce.failure "It looked like you had already issued a token, but deleting it didn't help. You're on your own at this point. You should should use the link at the start to generate a token manually."
      end
    end

    def self.delete_existing_authorization(session, headers)
      existing = old_auth_tokens('git-ready', session, headers).first[:id]
      session.delete_authorization existing, headers: headers
    end

    def self.old_auth_tokens(note, session, headers)
      session.authorizations(headers: headers).select do |auth|
        auth[:note] == note
      end
    end

    def self.works?(token)
      github = Octokit::Client.new access_token: token
      true if github.repos
    rescue Octokit::Unauthorized
      Announce.failure 'Invalid Credentials'
      false
    end
  end
end
