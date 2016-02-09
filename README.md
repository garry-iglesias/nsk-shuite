# NoStress Kommando Shell Scripts

This is a collection of *"Kommando-style"* command line scripts for various
development and administrative tasks.

Those tools require very few dependencies and relies on common GNU/POSIX tools,
principally BASH, grep, sed, awk...

There are useful in "Kommando" situation: dev-ops, remote system administration,
embedded devices development and deployment, server, etc.

Globally what can be useful to a {System Administrator|System Developper|Power User}
when often bootstrapping or working on lightweight systems with few tools installed.

Higher-level languages like Perl and Python requires some setup and sometimes we
don't have the luxury to have those powerful tools.

Although this collection of script can easily join your own collection of tools written
in whatever language you want, as they mostly follow "Unix Common Sens" and are quite
flexible and often very easy to configure, wheter it is manually or automatically.

*[Slackware][slackw] Note:* Slackware being my prefered working and development system
some of those tools are specifically targetted at this lovely distribution.

*To Slack or not to Slack ? Slack is the question !*

----

## Overview

I'll try to keep a list of all scripts here, but the best source will still
be the actual file contents. Usually each tool have its own '*README.md*'.

* *qnd-install* - a "quick'n'dirty" installer, which can help installing some of
the standalone tools releases as "single-file-scripts".
* *scvc* - a configuration file version control based upon git.
* *kha* - Kommando Hack Assistant, a command line companion for a couple of
IT tasks (like managing rsyn/ftp/http mirrors and git repository mirrors).
* *rgit* - a local git repositories tool (easy {pull from}/{push to} a group of repos).
* *kom-autobuild* - an automatic build tool, tracking a git branch.
* *kom-publish* - a git repository digest (filtered working tree) publishing tool.
* *ssh-tools* - a collection of 'humble scripts' to assist SSH setup.

[slackw]: http://www.slackware.com/ "Slackware Home Page"
