# NoStress Kommando Hack Assist

----

## Overview

> A command line Kommando companion tool. It compiles a collection of commands
> and is plugin-extensible.
>
> Basic usage:
>
> >    $ kha help

## Installation

> * Get the sources from a git repo or from an archive.
> * Execute *kha* script with the following command:
>
> >    $ path/to/kha/kha install-self
>
> *Kha* installs itself in <code>${HOME}/</code> by default, and it is the
> recommended root. Kha main script is stored in <code>${HOME}/bin</code>
> and Kha data in <code>${HOME}/.kha</code>.
>
> *install-self* command accept some options:
>
> * *--prefix <root-path>* - select another installation root directory (default is $HOME).
> * *--global* - do a 'global' installation (Experimental).
> * *--local* - do a 'local' installation (Default). Local means "user reserved".
> * *--sym-links* - do not copy scripts, instead create sym-links to the original installation
> files (the one from the repo). This is interesting when you develop in *kha* (plugins) or
> just to have 'implicit' update, as far as possible, just pulling *kha* repo.
> * *--portable* - do NOT create sym-links, instead do a 'portable' installation. Independent
> from the original installation files.
> * *--with-plugins* - install default plugins.
> * *--no-plugin* - do not install default plugins.
> * *--run-setup* - launch setup for each plugins.
> * *--no-setup* - do not launch setup.
>
> After installation you should confirm that the <code>*/bin</code> installation directory is
> present in your PATH environment, or add it.
>
> You can now invoke *kha* simply:
>
> >    $ kha [options] <kommand>  [kommand-options] [kommand-args]
>
> You can always get help using:
>
> >    $ kha help
>
>       or
>
> >    $ kha help <kommand>
>
> The latter might not give more help, depending on the command and the plugin.
>
> *Note:* As a reference, a typical installation command when you want to install
> as I install myself, to be able to develop for *kha* or its plugins:
>
> >    $ ./kha install-self --sym-links --with-plugins --run-setup

----

## Base commands

----

## Default plugins

----

## Installing a plugin

----

## Creating a plugin
