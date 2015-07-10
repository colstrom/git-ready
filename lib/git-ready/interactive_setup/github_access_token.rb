require 'contracts'
require 'highline/import'
require 'octokit'
require 'terminal-announce'

module InteractiveSetup
  module GitHubAccessToken
    include Contracts

    Contract None => String
    def self.setup
      Announce.info 'If you leave this blank, git-ready will do most of the work for you. As a fallback, you can generate your own at https://github.com/settings/tokens/new'
      token = ask 'Enter your GitHub Personal Access Token:', String
      generated = guided_generation if token.empty?
      token = generated[:token] if generated
      token_works?(token) ? token : setup
    end

    Contract None => Hash
    def self.guided_generation
      login = ask_login
      password = ask_password
      generate login, password
    rescue Octokit::OneTimePasswordRequired
      Announce.info 'Your account has 2-Factor Authentication enabled. Awesome!'
      headers = { 'X-GitHub-OTP' => ask('Enter a valid 2-Factor Auth Token') }
      generate login, password, headers
    end

    Contract None => String
    def self.ask_login
      login = ask('Enter your GitHub login:')
      login.empty? ? ask_login : login
    end

    Contract None => String
    def self.ask_password
      password = ask('Enter your GitHub password:') { |input| input.echo = '*' }
      password.empty? ? ask_password : password
    end

    Contract String, String, Hash, Bool => Hash
    def self.generate(login, password, headers = {}, first_attempt: true)
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
        generate login, password, headers, first_attempt: false
      else
        Announce.failure "It looked like you had already issued a token, but deleting it didn't help. You're on your own at this point. You should should use the link at the start to generate a token manually."
      end
    end

    Contract Octokit::Client, Hash => Any
    def self.delete_existing_authorization(session, headers)
      existing = old_auth_tokens('git-ready', session, headers).first[:id]
      session.delete_authorization existing, headers: headers
    end

    Contract String, Octokit::Client, Hash => Any
    def self.old_auth_tokens(note, session, headers)
      session.authorizations(headers: headers).select do |auth|
        auth[:note] == note
      end
    end

    Contract String => Bool
    def self.token_works?(token)
      github = Octokit::Client.new access_token: token
      true if github.repos
    rescue Octokit::Unauthorized
      Announce.failure 'Invalid Credentials'
      false
    end
  end
end
