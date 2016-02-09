###############################################################################
# KHA Plugin: 'repository'
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
# KHA repository plugin default content:
###############################################################################

#######################################
repo-genDefaultConf () {
        cat <<KHA_REPO_DEFAULT_CONF
###############################################################################
# KHA - Repository Configuration.
###############################################################################

#######################################
# Repository root:
KHA_REPO_ROOT="\${KHA_VAR_PATH}/repo"

KHA_REPO_DEFAULT_CONF
}

###############################################################################
# KHA repository plugin kontext:
###############################################################################

#######################################
# Repository kontext layout:
readonly KHAKTX_REPO_CONF_NAME='repository.conf'

#######################################
repo-openEnv () {
    KHA_REPO_CONF="${KHA_ETC_PATH}/${KHAKTX_REPO_CONF_NAME}"
}

#######################################
repo-defConfEnv () {
    KHA_REPO_ROOT="${KHA_REPO_ROOT:-${KHA_VAR_PATH}/repo}"
}

#######################################
repo-postConfEnv () {
    KHA_REPO_GITIGNORE="${KHA_REPO_ROOT}/.gitignore"
}

#######################################
repo-shutEnv () {
    unset \
        KHA_REPO_CONF
}

#######################################
repo-loadConf () {
    repo-defConfEnv
    source "${KHA_REPO_CONF}"
    repo-postConfEnv
}

#######################################
repo-loadEnv () {
    repo-openEnv

    # Check configuration file presence:
    [[ -f "${KHA_REPO_CONF}" ]] || kha-error "Missing configuration at: '${KHA_REPO_CONF}'"

    # Ok so load the configuration environment:
    repo-loadConf
}

#######################################
repo-setupEnv () {
    # Static repo environment:
    repo-openEnv

    # Setup configuration:
    [[ -f "${KHA_REPO_CONF}" ]] \
        || repo-genDefaultConf >"${KHA_REPO_CONF}"

    # User can tweak it:
    kha-edit "${KHA_REPO_CONF}"

    # Now we can load configuration:
    repo-loadConf

    # Check directories:
    kha-ensureDir "${KHA_REPO_ROOT}"

    # Check gitignore:
    [[ -f "${KHA_REPO_GITIGNORE}" ]] \
        || cat >"${KHA_REPO_GITIGNORE}" <<REPO_DEFAULT_GITIGNORE
# KHA Repository.

# Well we might want to simply ignore everything there... :)
*

REPO_DEFAULT_GITIGNORE

    # Clear environment:
    repo-shutEnv
}

#######################################
repo-exeK () {
    local cmd="$1" retVal=0 ; shift
    repo-loadEnv
    "$cmd" "$@" || retVal=$?
    repo-shutEnv
    return $retVal
}

###############################################################################
# KHA repository plugin library:
###############################################################################


###############################################################################
# KHA repository Command Line Interface:
###############################################################################
# Kommands accessible directly as KHA's kommands on the CLI.

#######################################
kmd-setup-repo () { ktx-exeK repo-setupEnv ; }

###############################################################################
# KHA repository plugin initialization:
###############################################################################
    
