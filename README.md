# git-ready

git-ready is a tool for quickly joining an organization on GitHub.

Installation
------------

`gem install git-ready`

OSX Installation Issues?
------------------------

One of the gems used by git-ready ([Rugged](https://github.com/libgit2/rugged)), requires `cmake` to build. On OSX, this isn't installed by default, but can easily be resolved with `brew install cmake`.

Usage
-----

`git-ready <organization>`

Configuration
-------------
git-ready will search for configuration files in the following places:
* /etc/git-ready.yaml
* /usr/local/etc/git-ready.yaml
* ~/.config/git-ready.yaml
* ./git-ready.yaml

These will be loaded in order, and any conflicting keys will be overwritten.

If no configuration is found, git-ready will enter _Interactive Setup Mode_, and attempt to guide you through setup. It will prompt for your GitHub username and password, so it can issue itself an auth token (with `repo` scope only) for future use. This will be written to the configuration file.

If your GitHub account uses 2-Factor Authentication, git-ready will prompt you for a 2FA token.

If you would prefer to set up an auth token manually, that is supported too.

License
-------
[MIT](https://tldrlegal.com/license/mit-license)

Contributors
------------
* [Chris Olstrom](https://colstrom.github.io/) | [e-mail](mailto:chris@olstrom.com) | [Twitter](https://twitter.com/ChrisOlstrom)
