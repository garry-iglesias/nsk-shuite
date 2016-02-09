###############################################################################
# KHA Plugin: 'repo-git'
# Author: Garry Iglesias <garry.iglesias@gmail.com>
###############################################################################
#
# This BASH script will be sourced on KHA initialization if his plugin is
# activated.
#
###############################################################################
#
# The main flow of this script is sourced on KHA's initialization, so the
# only imperative code should do initialization, if required.
#
# Generally, a plugin consist more of a library of functions, to enhance
# the KHA features enriching the KHA's environment.
#
# It is easy to expose a new Command Line "Kommand" simply prefixing your
# function with 'kmd-'.
#
###############################################################################
# Developer notes:
#
# Performances / Resources:
#  - it is better not to "bloat" environment when not needed. So if you provide
# a large function library, provide "lazy loading" function to source external
# files "on demand".
#
###############################################################################

###############################################################################
# KHA repo-git Layout:
###############################################################################

readonly KHAKTX_REPGIT_CONFIG_NAME='gitrepo.conf'
readonly KHAKTX_REPGIT_TAB_NAME='gitrepotab'

###############################################################################
# KHA repo-git default sources:
###############################################################################

#######################################
repGit-defaultConfiguration () {
    cat <<DEFAULT_GITREPO_CONFIGURATION
###############################################################################
#
# KHA - Git Repositories - Configuration.
#
###############################################################################
# This is a BASH configuration script.

#######################################
KHA_REPO_GIT_ROOT="\${KHA_REPO_ROOT}/git"

#######################################
NSHQ_GITREPO_BASE='ssh://username@some.server.net/repo/nsgit'

DEFAULT_GITREPO_CONFIGURATION
}

#######################################
repGit-defaultTab () {
    cat <<DEFAULT_GITREPO_TAB
###############################################################################
# KHA Git Repositories tab.
#
# Format:
# <Repo Name>|<Remote Repository Address>|
#
# Warning: Trailing Pipe (|) is MANDANTORY.
#
###############################################################################

#######################################
# NoStress HQ Git Repository Source:
#nsKommandOS|\${NSHQ_GITREPO_BASE}/nsKommandOS.git|
#gi-bubbleChamber|\${NSHQ_GITREPO_BASE}/gi-bubbleChamber.git|

#######################################
# Third parties git repositories:
#gitstats|git://github.com/hoxu/gitstats.git|
#gitinspector|https://code.google.com/p/gitinspector/|

DEFAULT_GITREPO_TAB
}

###############################################################################
# KHA repo-git Kontext:
###############################################################################

#######################################
repGit-openEnv () {
    KHA_REPO_GIT_CONFIG="${KHA_ETC_PATH}/${KHAKTX_REPGIT_CONFIG_NAME}"
    KHA_REPO_GIT_TAB="${KHA_ETC_PATH}/${KHAKTX_REPGIT_TAB_NAME}"
}

#######################################
repGit-defConfEnv () {
    KHA_REPO_GIT_ROOT="${KHA_REPO_ROOT}/git"
}

#######################################
repGit-postConfEnv () { : ; }

#######################################
repGit-shutEnv () {
    unset \
        KHA_REPO_GIT_CONFIG \
        KHA_REPO_GIT_TAB \
        KHA_REPO_GIT_ROOT
}

#######################################
repGit-loadConf () {
    [[ -f "$KHA_REPO_GIT_CONFIG" ]] \
        || kha-error "KHA repo-git configuration file not found !"

    repGit-defConfEnv
    source "$KHA_REPO_GIT_CONFIG" || kha-error "Error reading repo-git configuration file !"
    repGit-postConfEnv
}

#######################################
repGit-loadEnv () {
    repGit-openEnv
    repGit-loadConf
}

#######################################
repGit-setupEnv () {
    repGit-openEnv

    # Check configuration:
    if ! [[ -f "$KHA_REPO_GIT_CONFIG" ]] ; then
        repGit-defaultConfiguration >"$KHA_REPO_GIT_CONFIG"
    fi

    # Check tab:
    if ! [[ -f "$KHA_REPO_GIT_TAB" ]] ; then
        repGit-defaultTab >"$KHA_REPO_GIT_TAB"
    fi

    # Edit the configuration:
    kha-edit "$KHA_REPO_GIT_CONFIG" "$KHA_REPO_GIT_TAB"

    repGit-shutEnv
}

#######################################
repGit-exeK () {
    local cmd="$1" reVal=0 ; shift
    repGit-loadEnv
    "$cmd" "$@" || retVal=$?
    repGit-shutEnv
    return $retVal
}

#######################################
repGit-repo-exeK () { repo-exeK repGit-exeK "$@" ; }
repGit-Ktx-exeK () { ktx-exeK repGit-repo-exeK "$@" ; }

###############################################################################
# KHA repo-git plugin library:
###############################################################################

#######################################
repGit-tab () { <"$KHA_REPO_GIT_TAB" kha-killKomments ; }

#######################################
repGit-tabNames () { repGit-tab | cut -d\| -f1 ; }
repGit-repoExists () { repGit-tab | grep -q "^$1|" ; }
repGit-recordFromName () { repGit-tab | grep "^$1|" ; }

#######################################
repGit-syncRepo () {
    local repoName="$1" repoRecord
    repoRecord="$(repGit-recordFromName "$repoName")"

    # Sanity check:
    [[ -n "$repoRecord" ]] \
        || kha-error "No repository found with the name: '${repoName}'."

    # Get git repo infos:
    local localRoot="${KHA_REPO_GIT_ROOT}"
    local localName="${repoName}.git"
    local localPath="${localRoot}/${localName}"
    local rawRemoteAddress evaURL
    rawRemoteAddress="$(echo "$repoRecord" | cut -d\| -f2)"
    evaURL="$(eval echo "$rawRemoteAddress")"

    # Check local root:
    kha-ensureDir "$localRoot"

    if [[ -d "$localPath" ]] ; then
        # Repository has already be cloned, we just
        # need to sync it:
        kha-verbose-echo " * Syncing git repository: '${repoName}'..."
        cd "$localPath"
        git fetch 'origin' \
            || kha-error "Fetching '${repoName}' failed !"
    else
        # Repository is "new", so we clone/mirror it:
        kha-verbose-echo " * Mirroring git repository: '${repoName}'..."
        cd "$localRoot"
        git clone --mirror --shared "$evaURL" "$localName" \
            || kha-error "Cloning '${repoName}' failed !"
    fi
}

#######################################
repGit-gcRepo () {
    local repoName="$1" repoRecord
    repoRecord="$(repGit-recordFromName "$repoName")"

    # Sanity check:
    [[ -n "$repoRecord" ]] \
        || kha-error "No repository found with the name: '${repoName}'."

    # Get git repo infos:
    local localRoot="${KHA_REPO_GIT_ROOT}"
    local localName="${repoName}.git"
    local localPath="${localRoot}/${localName}"

    # Do the garbace collection:
    kha-verbose-echo " * Garbage collecting git repository: '${repoName}'..."
    local oldSize newSize
    cd "$localPath"
    oldSize="$(du -bhs)"
    git gc
    newSize="$(du -bhs)"
    kha-verbose-echo " -> Repo size: $oldSize -> $newSize"
}

#######################################
repGit-parseRepoList () {
    # Prepare list:
    local repList curArg cmdName="$1"
    repList="$(kha-mktemp)"
    shift
    # Parse arguments for repos:
    [[ -n "${1:-}" ]] || kha-error "Usage: ${cmdName} [--all | gitrepo-name-1 [gitrepo-name-2 [...]]]"
    while [[ -n "${1:-}" ]] ; do
        curArg="$1" ; shift
        case "${curArg}" in
            '--all') # Request all repos:
                kha-verbose-echo " * All repos request."
                repGit-tabNames >>"$repList"
                ;;
            *) # So is this really a mirror ?
                ( repGit-tab | grep -q "^${curArg}|" ) \
                    || kha-error "Repo '${curArg}' is unknown !"
                # Ok so take him:
                echo "$curArg" >>"$repList"
                ;;
        esac
    done
    # Clean the list:
    <"$repList" sort -u | kha-source-redirect "$repList"
    # Echoes the list name:
    echo "$repList"
   
}

#######################################
repGit-sync () {
    # Build the repo list from arguments:
    local repoList
    repoList="$(repGit-parseRepoList 'repgit-sync' "$@" )"

    # Now scan the list and do the sync:
    local repoName
    while IFS= read repoName || [[ -n "$repoName" ]] ; do
        repGit-syncRepo "$repoName"
    done <"$repoList"
    rm "$repoList"
}

#######################################
repGit-gc () {
    # Build the repo list from arguments:
    local repoList
    repoList="$(repGit-parseRepoList 'repgit-sync' "$@" )"

    # Now scan the list and do the sync:
    local repoName
    while IFS= read repoName || [[ -n "$repoName" ]] ; do
        repGit-gcRepo "$repoName"
    done <"$repoList"
    rm "$repoList"
}

###############################################################################
# KHA repo-git Command Line Interface:
###############################################################################
# Kommands accessible directly as KHA's kommands on the CLI.

#######################################
kmd-setup-repogit () { ktx-exeK repGit-setupEnv ; }

#######################################
kmd-repogit-sync () { repGit-Ktx-exeK repGit-sync "$@" ; }

#######################################
kmd-repogit-gc () { repGit-Ktx-exeK repGit-gc "$@" ; }

###############################################################################
# KHA repo-git plugin initialization:
###############################################################################

