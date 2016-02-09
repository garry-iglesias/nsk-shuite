###############################################################################
# KHA Plugin: 'repo-mirror'
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
# the KHA features enhancing the KHA's environment.
#
# It is easy to expose a new Command Line "Kommand" simply prefixing your
# function with 'kmd-'.
#
###############################################################################

###############################################################################
# KHA repo-mirror default content:
###############################################################################

#######################################
repMir-defaultMirrorConf () {
    cat <<KHA_DEFAULT_MIRROR_CONF
###############################################################################
# KHA Repo Mirror Configuration.
###############################################################################

KHA_MIRROR_ROOT="\${KHA_REPO_ROOT}/mirrors"

#######################################
# Mirrors sources:
SLACKWARE_RSYNC_MIRROR='slackware.org.uk/slackware'
SALIX_RSYNC_MIRROR='salix.enialis.net/salix'
CTAN_RSYNC_MIRROR='distrib-coffee.ipsl.jussieu.fr/pub/mirrors/ctan'
ALIEN_PASTURES_HTTP_MIRROR='www.slackware.com/~alien/slackbuilds'
ALIEN_PASTURES_RSYNC_MIRROR='taper.alienbase.nl/mirrors/people/alien/slackbuilds'
ALIEN_PASTURES_RESTRICTED_RSYNC_MIRROR='taper.alienbase.nl/mirrors/people/alien/restricted_slackbuilds'

#######################################
# Slackware mirror package exclusions:
SLACK_EXCLUDES='kdei%y%source'

KHA_DEFAULT_MIRROR_CONF
}

#######################################
repMir-defaultMirrorTab () {
    cat <<KHA_DEFAULT_MIRROR_TAB
###############################################################################
# KHA Repo Mirror table.
# Format:
# <Mirror Name>|<Repo Prefix>|<Source URL>|<Exclusion List>|
#
# Warning: Trailing pipe (|) is MANDATORY.
#
# <Mirror Name> can be freely choosen.
# <Repo Prefix> can be empty, will be evaluated (can contains variable references).
#
# <Source URL> will be evaluated (can contains variable references).
#    it can start with: 'http://', 'ftp://', or 'rsync://'.
#
# <Exclusion List> will be evaluated. Separator is %.
#
###############################################################################

#######################################
# 32bit Slackware:
#slackware-13.37|slackware|rsync://\${SLACKWARE_RSYNC_MIRROR}/slackware-13.37|\${SLACK_EXCLUDES}|
#slackware-14.0|slackware|rsync://\${SLACKWARE_RSYNC_MIRROR}/slackware-14.0|\${SLACK_EXCLUDES}|
#slackware-14.1|slackware|rsync://\${SLACKWARE_RSYNC_MIRROR}/slackware-14.1|\${SLACK_EXCLUDES}|
#slackware-current|slackware|rsync://\${SLACKWARE_RSYNC_MIRROR}/slackware-current|\${SLACK_EXCLUDES}|

#######################################
# 64bit Slackware:
#slackware64-13.37|slackware|rsync://\${SLACKWARE_RSYNC_MIRROR}/slackware64-13.37|\${SLACK_EXCLUDES}|
#slackware64-14.0|slackware|rsync://\${SLACKWARE_RSYNC_MIRROR}/slackware64-14.0|\${SLACK_EXCLUDES}|
#slackware64-14.1|slackware|rsync://\${SLACKWARE_RSYNC_MIRROR}/slackware64-14.1|\${SLACK_EXCLUDES}|
#slackware64-current|slackware|rsync://\${SLACKWARE_RSYNC_MIRROR}/slackware64-current|\${SLACK_EXCLUDES}|

#######################################
# Alien BOB Repository:

# Unrestricted:
#libreOffice64|alienBob/libreoffice/pkg64|http://\${ALIEN_PASTURES_HTTP_MIRROR}/libreoffice/pkg64|
#libreOffice64|alienBob/libreoffice|rsync://\${ALIEN_PASTURES_RSYNC_MIRROR}/libreoffice/pkg64|
#veracrypt|alienBob|rsync://\${ALIEN_PASTURES_RSYNC_MIRROR}/veracrypt|
#ffmpeg|alienBob|rsync://\${ALIEN_PASTURES_RSYNC_MIRROR}/ffmpeg|
#wine|alienBob|rsync://\${ALIEN_PASTURES_RSYNC_MIRROR}/wine|
#openjdk|alienBob|rsync://\${ALIEN_PASTURES_RSYNC_MIRROR}/openjdk|
#tigervnc|alienBob|rsync://\${ALIEN_PASTURES_RSYNC_MIRROR}/tigervnc|

# US-Patents restricted:
#vlc|alienBob|rsync://\${ALIEN_PASTURES_RESTRICTED_RSYNC_MIRROR}/vlc|


#######################################
# Salix Repository:
#salix-14.0|salix/i486|rsync://\${SALIX_RSYNC_MIRROR}/i486/14.0|
#salix-14.1|salix/i486|rsync://\${SALIX_RSYNC_MIRROR}/i486/14.1|
#salix64-14.0|salix/x86_64|rsync://\${SALIX_RSYNC_MIRROR}/x86_64/14.0|
#salix64-14.1|salix/x86_64|rsync://\${SALIX_RSYNC_MIRROR}/x86_64/14.1|

#######################################
# CTAN (Tex LIVE) Repository:
#texlive|texlive|rsync://\${CTAN_RSYNC_MIRROR}/systems/texlive/tlnet|

KHA_DEFAULT_MIRROR_TAB
}

###############################################################################
# KHA repo-mirror kontext:
###############################################################################

#######################################
# Repo Mirror Layout:
readonly KHAKTX_MIRROR_CONF_NAME='mirror.conf'
readonly KHAKTX_MIRROR_TAB_NAME='mirrortab'

#######################################
repMir-openEnv () {
    KHA_MIRROR_CONF="${KHA_ETC_PATH}/${KHAKTX_MIRROR_CONF_NAME}"
    KHA_MIRROR_TAB="${KHA_ETC_PATH}/${KHAKTX_MIRROR_TAB_NAME}"
}

#######################################
repMir-closeEnv () {
    unset \
        KHA_MIRROR_CONF KHA_MIRROR_TAB
}

#######################################
repMir-loadEnv () {
    # Open mirror environment:
    repMir-openEnv

    # Load Mirror configuration:
    [[ -f "${KHA_MIRROR_CONF}" ]] \
        || kha-error "Missing repo-mirror configuration at: $KHA_MIRROR_CONF"

    source "${KHA_MIRROR_CONF}" || kha-error "Failed to load 'repo-mirror' configuration !"
}

#######################################
repMir-setupEnv () {
    repMir-openEnv

    # Setup mirror configuration:
    if ! [[ -f "${KHA_MIRROR_CONF}" ]] ; then
        repMir-defaultMirrorConf >"${KHA_MIRROR_CONF}"
    fi

    # Setup mirror tab:
    if ! [[ -f "${KHA_MIRROR_TAB}" ]] ; then
        repMir-defaultMirrorTab >"${KHA_MIRROR_TAB}"
    fi

    kha-edit "${KHA_MIRROR_CONF}" "${KHA_MIRROR_TAB}"

    repMir-closeEnv
}

#######################################
repMir-exeK () {
    local mirCmd="$1" retVal=0 ; shift
    repMir-loadEnv
    "$mirCmd" "$@" || retVal=$?
    repMir-closeEnv
    return $retVal
}

#######################################
repMir-repoExeK () { repo-exeK repMir-exeK "$@" ; }
repMir-fullKtxExeK () { ktx-exeK repo-exeK repMir-exeK "$@" ; }

###############################################################################
# KHA repo-mirror internals:
###############################################################################

#######################################
repMir-mirrotab () { <"${KHA_MIRROR_TAB}" kha-killKomments ; }

###############################################################################
# KHA repo-mirror plugin library:
###############################################################################

#######################################
#readonly KHA_REPO_DEFAULT_NAME='repo'

#######################################
# Configurable environment:
#KHA_REPO_ROOT="${KHA_VAR_PATH}/${KHA_REPO_DEFAULT_NAME}"

#######################################
repMir-parseMirrorList () {
    # Prepare list:
    local mirList curArg cmdName="$1"
    mirList="$(kha-mktemp)"
    shift
    # Parse arguments for mirrors:
    [[ -n "${1:-}" ]] || kha-error "Usage: ${cmdName} [--all | mirror-name-1 [mirror-name-2 [...]]]"
    while [[ -n "${1:-}" ]] ; do
        curArg="$1" ; shift
        case "${curArg}" in
            '--all') # Request all mirrors:
                kha-verbose-echo " * All mirrors request."
                repMir-mirrotab | cut -d\| -f1 >>"$mirList"
                ;;
            *) # So is this really a mirror ?
                ( repMir-mirrotab | grep -q "^${curArg}|" ) \
                    || kha-error "Mirror '${curArg}' is unknown !"
                # Ok so take him:
                echo "$curArg" >>"$mirList"
                ;;
        esac
    done
    # Clean the list:
    <"$mirList" sort -u | kha-source-redirect "$mirList"
    # Echoes the list name:
    echo "$mirList"
   
}

#######################################
repMir-rsync () {
#    echo "rsync:" "$@" >&2
    
    local srcURL="$1" tgtDir="$2"
    local xcludes=()
    shift 2
    while [[ -n "${1:-}" ]] ; do
	xcludes+=( '--exclude' )
	xcludes+=( "$1" )
	shift
    done
    #if [[ -n "${xcludes:-}" ]] && (( ${#xcludes} )) ; then
    #if (( ${#xcludes} )) ; then
    if [[ -n "${xcludes:-}" ]] ; then
	cd "$tgtDir" \
            && rsync -rlptDvz \
            --delete --delete-excluded \
	    "${xcludes[@]}" \
            "$srcURL" \
            .
    else
	cd "$tgtDir" \
            && rsync -rlptDvz \
            --delete \
            "$srcURL" \
            .
    fi
}

#######################################
repMir-ftp () {
    local srcURL="$1" tgtDir="$2"
    kha-wip
}

#######################################
repMir-http () {
    local srcURL="$1" tgtDir="$2"

    kha-verbose-echo "HTTP '$srcURL' -> '$tgtDir'"
    cd "$tgtDir" \
	&& lftp -c "open '${srcURL}'; mirror -en --loop ."
}

#######################################
repMir-ssh () {
    local srcURL="$1" tgtDir="$2"
    kha-wip
}

#######################################
repMir-fetchMirror () {
    # Get mirror name:
    local mirName="$1"
    kha-verbose-echo " * Mirroring '${mirName}'..."

    # Load mirror record:
    local mirRec mirDir mirURL mirXcl evaDir evaURL evaXcl
    mirRec="$( repMir-mirrotab | grep "^${mirName}|" )"
    mirDir="$( echo "$mirRec" | cut -d\| -f2 )"
    mirURL="$( echo "$mirRec" | cut -d\| -f3 )"
    mirXcl="$( echo "$mirRec" | cut -d\| -f4 )"
   
    # Evaluate the fields:
    evaDir="$( eval echo "$mirDir" )"
    evaURL="$( eval echo "$mirURL" )"
    evaXcl="$( eval echo "$mirXcl" )"

    # Build local mirror path:
    local localDir="${KHA_MIRROR_ROOT}"
    [[ -z "${evaDir}" ]] || localDir="${localDir}/${evaDir}"
    #localDir="${localDir}/${mirName}"

    # Some mirror briefing:
    (( 1 )) || kha-verbose-cat <<MIRROR_BRIEF
==== Mirror: ${mirName} ====
Remote Source: ${evaURL}
Local Path: ${localDir}
Exluded: ${evaXcl}

MIRROR_BRIEF

    # Check local dir:
    [[ -d "$localDir" ]] \
        || mkdir -p "$localDir" \
        || kha-error "Unable to create directory: '$localDir'"

    # Build exclude list:
    local xcluded="$(kha-mktemp)"
    echo "${evaXcl}" | tr '%' '\n' >>"$xcluded"

    # Do the mirror:
    case "${evaURL}" in
        'rsync://'*) <"$xcluded" kha-xargs repMir-rsync "$evaURL" "$localDir" ;;
        'ftp://'*) <"$xcluded" rkha-xargs epMir-ftp "$evaURL" "$localDir" ;;
        'http://'*) <"$xcluded" kha-xargs repMir-http "$evaURL" "$localDir" ;;
        'https://'*) <"$xcluded" kha-xargs repMir-http "$evaURL" "$localDir" ;;
        'ssh://'*) <"$xcluded" kha-xargs repMir-ssh "$evaURL" "$localDir" ;;
        *) kha-error "Unknown protocol for mirror: ${mirDir} (${evaURL}) !" ;;
    esac
}

#######################################
kha-xargs () {
    local args=( "$@" ) appArg
    while IFS= read appArg ; do args+=( "$appArg" ) ; done
#    kha-verbose-echo "args=${args[@]}"
    "${args[@]}"
}

#######################################
repMir-fetchMirrors () {
    # Parse the mirror list:
    local mirList
    mirList="$( repMir-parseMirrorList 'fetch' "$@" )"
    # Now fetch mirrors:
    local eachMirror
    while IFS= read eachMirror ; do
        repMir-fetchMirror "${eachMirror}"
    done <"$mirList"
}

###############################################################################
# KHA repo-mirror Command Line Interface:
###############################################################################
# Kommands accessible directly as KHA's kommands on the CLI.

#######################################
kmd-setup-mirror () { ktx-exeK repo-exeK repMir-setupEnv ; }
kmd-mirror-sync () { repMir-fullKtxExeK repMir-fetchMirrors "$@" ; }

#######################################
kmd-mirror () {
    # Mirror command line evaluation:
    local curArg isCmd=0
    while [[ -n "${1:-}" ]] ; do
        curArg="$1" ; shift
        case "${curArg}" in
            *) kha-error "Invalid mirror argument '${curArg}' !" ;;
        esac
    done
    (( isCmd )) || kha-error-cat <<MIRROR_NO_ARG
mirror command requires some active aguments in order to do something useful. :)

Try:
  \$ ${KHA_NAME} help mirror

MIRROR_NO_ARG
}

###############################################################################
# KHA repo-mirror plugin initialization:
###############################################################################
kha-requirePlugins 'repository'
    
