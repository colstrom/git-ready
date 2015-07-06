require 'contracts'
require 'octokit'
require 'progress_bar'
require_relative 'settings'

module GitHub
  include Contracts

  Contract String => ArrayOf[({ upstream: Sawyer::Resource, origin: Sawyer::Resource })]
  def self.fork_all(organization)
    repositories = %w(public, private).flat_map do |type|
      api.org_repos(organization, type: type)
    end
    progress = ProgressBar.new repositories.length
    repositories.flat_map do |repository|
      progress.increment!
      { upstream: repository, origin: api.fork(repository[:full_name]) }
    end
  end

  Contract nil => Octokit::Client
  def self.api
    @api ||= Octokit::Client.new access_token: Settings.github_access_token, auto_paginate: true
  end
end
