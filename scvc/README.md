# NoStress System Configuration Version Control.

----

## Overview

> A simple command line tool to manage configuration files version control.
> It uses git to store different revision of selected tracked files on the
> file system.
>
> It can be used as a simple user to share / backup / version control user
> configuration in his "HOME".
>
> It also, and was created primary for managing several servers and workstations
> configurations, being able to easily track changes and rollback sensible
> configuration files when updating system or doing various changes.
>
> *Warning:* This is a *tool* to help a power user, it *REQUIRES* its user
> to have knowledge to what is dangerous and the limits of configuration file
> versioning. *scvc* does *NOT* choose which file is important or not for you,
> it is up to you to select them wisely.

----

## Warning

> *WARNING:* This utility handles HIGHLY SENSITIVE files ! You should know what
> you do, being a wise system administrator.
>
> *DO NOT COPY OR CLONE DATABASE TO SOME ACCESSIBLE LOCATION !!*
> *DATABASE CAN HOLD SYSTEM PASSWORDS AND SECURITY CONFIGURATION FILES !!*

----

## Usage

### Installation
> *scvc* is a single script file. You can copy it in a directory accessible in
> your *PATH* environment variable.

### Invocation:
>
>     # scvc [options] [command] [arg1 [arg2 [arg3 [...]]]]
>
> Where command can be one of the following:
>
> * help
> * listTracked[{Files|Directories}]
> * track [pathToTrack]
> * trackedCheck
> * edit{Config|Ignore|Tracked[{Files|Directories}]}
> * snapshot
> * pushRepo
> * snapAndPush
> * gcRepo
> * wipeRepo
> * listCommands
>
> *Advices:*
>
> * make a snapshot after each configuration change, or group of changes.
> * make a snapshot BEFORE AND AFTER each system upgrade, easier to rollback
> changes, and to be sure you have a backup of the last state before updating.
> * make a script for system update that snapshot automatically.

----
