# Quick'n'dirty executable installer

----

## Overview

> A very simple script that helps to "install" some files into the
> *${TARGET_PREFIX}/bin* directory.

> It uses a symbolic link to the source.

> This script is useful if you have a collection of various scripts that
> you may still develop, and 'quickly' make a link into a directory in the
> path.

> It is *NOT* intended to be an "official" installer or a complex one, it's
> just a helper for the "Kommando Hackers".

## Usage

> >    $ qnd-install [file1 [file2 [...]]]

> It will create a symbolic links into the directory specified by the environment
> variable *TARGET_BIN*.

> * *TARGET_BIN* default value: *TARGET_PREFIX*/bin
> * *TARGET_PREFIX* default value: *HOME*/bin

> So as it, *qnd-install* will create links into *~/bin*.

> If you want another destination (ie: for a global install as root):

> >    $ *TARGET_PREFIX*=/ *qnd-install* <some-file>

> This will 'install' <some-file> into */bin*.
