Gem::Specification.new do |gem|
  tag = `git describe --tags --abbrev=0`.chomp

  gem.name     = 'git-ready'
  gem.homepage = 'http://github.com/colstrom/git-ready'
  gem.summary  = 'git-ready gets you ready to work with an established team that already uses GitHub.'

  gem.version  = "#{tag}"
  gem.licenses = ['MIT']
  gem.authors  = ['Chris Olstrom']
  gem.email    = 'chris@olstrom.com'

  gem.cert_chain    = ['trust/certificates/colstrom.pem']
  gem.signing_key   = File.expand_path ENV.fetch 'GEM_SIGNING_KEY'

  gem.files         = `git ls-files -z`.split("\x0")
  gem.test_files    = `git ls-files -z -- {test,spec,features}/*`.split("\x0")
  gem.executables   = `git ls-files -z -- bin/*`.split("\x0").map { |f| File.basename(f) }

  gem.require_paths = ['lib']

  gem.add_runtime_dependency 'contracts',         '~> 0.9'
  gem.add_runtime_dependency 'octokit',           '~> 4.0.0'
  gem.add_runtime_dependency 'progress_bar',      '~> 1.0.0'
  gem.add_runtime_dependency 'rugged',            '~> 0.23.0b0'
  gem.add_runtime_dependency 'settingslogic',     '~> 2.0.0'
  gem.add_runtime_dependency 'terminal-announce', '~> 1.0.0'
end

