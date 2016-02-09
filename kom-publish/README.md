# NoStress Kommando Repository Publisher.

Git-Repository "Digest" Publisher.

----

## Overview

> *kom-publisher* (*kpub*) is a command-line tool help to support "sub-repository",
> or "digest", or "cherry-picked" portion of a repository to 'publish' a
> new revision on a "publishing repo".

> Basic Use Case:

> * A private (restricted) repository is used for the core dev team.
> * A public (ie: github) repository is used to expose revisions of a
> set of files in the private repository.

> *kpub* can track a specific branch in the private repository, and whenever a new
> revision is detected, it process the working files and extract specifically
> selected files and directories and 'post' them in the public repository as a new
> revision in the 'publishing' branch of the target public rep.

> WARNING: this BASH script requires some common 'Unix' tools (grep, sed, ...)
> For now it has only be tested and used in GNU/Linux user space. I'm OK with
> contributions to help porting to BSD, MacOS, ...

---

## Usage

> ### Installation:

> > *Kommando publisher* is a single standalone BASH script that just requires to be
> > present in your PATH (or not, depending of your needs...).

> ### Invocation:

> >    $ kom-publish [command]

> Where *[command]* can be one of the following:

> * *help* - a help screen.
> * *init* [\<path>] - initialize a *kpub* project.
> * *publish* [\<path>] - check for a publish opportunity.
> * *publish-all* [\<path>] - check all sub-dirs for *kpub* projects and publish'em.

----

## Documentation

> For now the most in-depth documentation should be available typing:

> >    $ kom-publish help

> By the way, this document might be improved in time, with more resources.
