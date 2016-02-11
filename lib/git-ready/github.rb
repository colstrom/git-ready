require 'contracts'
require 'octokit'
require 'progress_bar'
require_relative 'settings'

module GitHub
  include Contracts

  Contract String, String => ArrayOf[({ upstream: Sawyer::Resource, origin: Sawyer::Resource })]
  def self.fork_all(organization, filter=nil)
    repositories = api.org_repos(organization).select { |repository| repository.name.include? filter }
    progress = ProgressBar.new repositories.length
    repositories.flat_map do |repository|
      progress.increment!
      { upstream: repository, origin: api.fork(repository[:full_name]) }
    end
  end

  Contract None => Octokit::Client
  def self.api
    @api ||= Octokit::Client.new access_token: Settings.github_access_token, auto_paginate: true
  end
end
