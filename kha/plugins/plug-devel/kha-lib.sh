###############################################################################
# KHA Plugin: 'plug-devel'
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
# KHA plug-devel Kontext:
###############################################################################

#######################################
plgDev-ctx-start () {
    KHA_PLGDEV_TAB="${KHA_ETC_PATH}/plgdevtab"
}

#######################################
plgDev-ctx-end () {
    unset \
        KHA_PLGDEV_TAB
}

#######################################
plgDev-ctx-load () {
    plgDev-ctx-start

    if ! [[ -f "$KHA_PLGDEV_TAB" ]] ; then
        cat >"$KHA_PLGDEV_TAB" <<PLUGDEV_DEFAULT_TAB
# KHA Plugin Development tab.
# Format:
# <Plugin Name>|<Publish Path>|
#
# <Publish Path> may contain variable references.
#
# ie:
# sample-plug|\$HOME/devel/dev-repo/plugins/sample-plug|
#
PLUGDEV_DEFAULT_TAB
    fi
}

#######################################
plgDev-exeK () {
    local cmd="$1" retVal=0 ; shift
    plgDev-ctx-load
    "$cmd" "$@" || retVal=$?
    plgDev-ctx-end
    return ${retVal}
}

###############################################################################
# Plug-dev internals:
###############################################################################

#######################################
plgDev-parsePlugList () {
    # Prepare publishing:
    local pubList curArg cmdName="$1"
    pubList="$(kha-mktemp)"
    shift
    # Parse arguments for plugins to publish:
    [[ -n "${1:-}" ]] || kha-error "Usage: ${cmdName} [--all | plugin-name-1 [plugin-name-2 [...]]]"
    while [[ -n "${1:-}" ]] ; do
        curArg="$1" ; shift
        case "${curArg}" in
            '--all') # Request all plugins:
                kha-verbose-echo " * All developped plugins request."
                plgDev-tab | cut -d\| -f1 >>"$pubList"
                ;;
            *) # So is this really a plugin ?
                kha-plug-exists "${curArg}" \
                    || kha-error "Plugin '${curArg}' is unknown !"
                # Ok so take him:
                echo "$curArg" >>"$pubList"
                ;;
        esac
    done
    # Clean the list:
    <"$pubList" sort -u | kha-source-redirect "$pubList"
    # Echoes the list name:
    echo "$pubList"
}


###############################################################################
# KHA plug-devel plugin library:
###############################################################################

#######################################
plgDev-tab () { <"$KHA_PLGDEV_TAB" kha-killKomments ; }

#######################################
plgDev-publishPlug () {
    # Load plugin name:
    local plugName="$1"

    kha-verbose-echo " * Publishing plugin: '${plugName}'..."

    # Load plugin tab's record:
    local plugRecord plugPubPath valPubPath
    plugRecord="$( plgDev-tab | grep "^${plugName}|" )"
    plugPubPath="$(echo "$plugRecord" | cut -d\| -f2 )"

    if [[ -n "${plugPubPath}" ]] ; then
        valPubPath="$( eval echo "$plugPubPath" )"

#        kha-debug-echo ">RECORD: '${plugRecord}'"
#        kha-debug-echo ">PUBPATH: '${valPubPath}'"

        # Now generate publishing's data:
        local plugSrc="${KHA_PLG_PATH}/${plugName}"
        local plugTgt="${valPubPath}/${plugName}"
        
        # Warn user:
        cat >/dev/tty <<PLUG_PUBLISH_KLOBBER_WARNING
WARNING: THIS OPERATION WILL OVERWRITE CONTENT AT:

${plugTgt}

AND YOU MAY LOSE DATA !!

THIS CANNOT BE UNDONE !

Press RETURN to continue...
PLUG_PUBLISH_KLOBBER_WARNING
        </dev/tty read -s
        
        # And publish it:
        kha-ensureDir "${plugTgt}"
        cp -r "${plugSrc}"/* "${plugTgt}"
    else kha-verbose-echo " ! Plugin have no publishing target !"
    fi
}

#######################################
#TODO: We should force a 'commit' of
# local KHA's repo changes....
plgDev-getPublicPlug () {
    # Load plugin name:
    local plugName="$1"

    kha-verbose-echo " * Acquiring public plugin: '${plugName}'..."

    # Load plugin tab's record:
    local plugRecord plugPubPath valPubPath
    plugRecord="$( plgDev-tab | grep "^${plugName}|" )"
    plugPubPath="$(echo "$plugRecord" | cut -d\| -f2 )"

    if [[ -n "${plugPubPath}" ]] ; then
        valPubPath="$( eval echo "$plugPubPath" )"

#        kha-debug-echo ">RECORD: '${plugRecord}'"
#        kha-debug-echo ">PUBPATH: '${valPubPath}'"

        # Now generate publishing's data:
        local plugSrc="${valPubPath}/${plugName}"
        local plugTgt="${KHA_PLG_PATH}/${plugName}"

        # Warn user:
        cat >/dev/tty <<PLUG_GET_KLOBBER_WARNING
WARNING: THIS OPERATION WILL OVERWRITE CONTENT AT:

${plugTgt}

AND YOU MAY LOSE DATA !!

THIS CANNOT BE UNDONE !

Press RETURN to continue...
PLUG_GET_KLOBBER_WARNING
        </dev/tty read -s
        
        # And get it:
        kha-ensureDir "${plugTgt}"
        cp -r "${plugSrc}"/* "${plugTgt}"
    else kha-verbose-echo " ! Plugin have no publishing target !"
    fi
}

#######################################
plgDev-publish () {
    # Parse the plugin list:
    local pubList
    pubList="$( plgDev-parsePlugList 'publish' "$@" )"
    # Now publish the plugins:
    local eachPlug
    while IFS= read eachPlug ; do
        plgDev-publishPlug "${eachPlug}"
    done <"$pubList"
}

#######################################
#TODO: We should force a 'commit' of
# local KHA's repo changes....
plgDev-getPublic () {
    # Parse the plugin list:
    local pubList
    pubList="$( plgDev-parsePlugList 'get-public' "$@" )"
    # Now get plugins from the 'public repo':
    local eachPlug
    while IFS= read eachPlug ; do
        plgDev-getPublicPlug "${eachPlug}"
    done <"$pubList"
}

#######################################
#TODO: Find a "nice format" for this one...
# For now this is most a "dev test" / sanity check
# based more that anything "useful".
plgDev-status () {
    plgDev-tab | while IFS= read plugRec ; do
        plugName="$(echo "$plugRec" | cut -d\| -f1)"
        plugDevPath="$(echo "$plugRec" | cut -d\| -f2)"
        plugRealPath="$(eval echo "$plugDevPath")"
        plugInstallPath="${KHA_PLG_PATH}/${plugName}"
        [[ -d "$plugInstallPath" ]] && instState="Installed" || instState="Missing"
        [[ -d "$plugRealPath" ]] && devState="Valid" || "Invalid"
        if [[ -h "$plugInstallPath" ]] ; then
            tgtPath="$("$LU_READLINK" "$plugInstallPath")"
            [[ -d "$tgtPath" ]] && instType='Sym-Linked' || instType='Sym-Link Broken'
        else instType='Static'
        fi
        printf "%13s '%s' Dev path is: '%s' - Install type: '%s'\n" "[${instState}]" "$plugName" "$devState" "$instType"
    done
}

###############################################################################
# KHA plug-devel Command Line Interface:
###############################################################################
# Kommands accessible directly as KHA's kommands on the CLI.

#######################################
kmd-plugd-edit-tab () {
    plgDev-ctx-load
    kha-edit "$KHA_PLGDEV_TAB"
    plgDev-ctx-end
}

#######################################
kmd-plugd-publish () { ktx-exeK plgDev-exeK plgDev-publish "$@" ; }
kmd-plugd-get-public () { ktx-exeK plgDev-exeK plgDev-getPublic "$@" ; }
kmd-plugd-status () { ktx-exeK plgDev-exeK plgDev-status "$@" ; }

#######################################
#foo () {
#    local curArg
#    while [[ -n "${1:-}" ]] ; do
#        curArg="$1"
#        case "${curArg}" in
#            *) kha-error "Invalid argument '${curArg}' !" ;;
#        esac
#    done
#}

###############################################################################
# KHA plug-devel plugin initialization:
###############################################################################

