# NoStress Kommando - Automatic Build System.

----

## Overview

> A simple, light-weighted and versatile, automatic build system, written in BASH.

> *kom-autobuild* uses git as version control system. There *might* be options for
> other VCS if really requested.

> Current usage is all-git-based.

> WARNING: this BASH script requires some common 'Unix' tools (grep, sed, ...)
> For now it has only be tested and used in GNU/Linux user space. I'm OK with
> contributions to help porting to BSD, MacOS, ...

----

## How it works

> A *kab* project (kommando autobuild) defines a repository and a branch to watch.
> Whenever a new revision appears, the builder starts a new build sequence according
> to the *kab* project definitions, and store the report in a "build report database".

> Several "handles" (hooks) are given in the *kab* project to execute special commands
> on special events (patch source tree, send a mail, update a web page, whatever is
> requested for the user build).

----

## Usage

> ### Installation:

> *Kommando Autobuild* is a single standalone BASH script that just requires to be
> present in your PATH (or not, depending of your needs...).

> ### Invocation:

> >    $ kom-autobuild [command]

> Where *[command]* can be one of the following:
>
> * *help* - a help screen.
> * *create* [\<path>] - Create a new *kab* project.
> * *build* [\<path>] - Build a *kab* project.

----

## Documentation

> For now the most in-depth documentation should be available typing:

> >    $ kom-autobuild help

> By the way, this document might be improved in time, with more resources.
