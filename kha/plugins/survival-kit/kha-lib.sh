###############################################################################
# KHA Plugin: 'survival-kit'
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
# KHA survival-kit plugin file layout.
###############################################################################

#######################################
readonly KSKKTX_CONFIG_NAME='survival-kit.conf'
readonly KSKKTX_RECIPES_DIR_NAME='survival-recipes'

###############################################################################
# KHA survival-kit plugin default sources snippets:
###############################################################################

#######################################
ksk-defaultConfig () {
    cat <<SURVIVALK_DEFAULT_CONFIG
###############################################################################
# KHA Survival Kit: Configuration file.
###############################################################################
# This is a BASH script configuration.

#######################################
# The survival recipes directory:
KSK_RECIPES_DIR="\${KSK_RECIPES_DIR:-\${KHA_VAR_PATH}/${KSKKTX_RECIPES_DIR_NAME}}"

SURVIVALK_DEFAULT_CONFIG
}

#######################################
ksk-defaultRecipe () {
    local recipeName="$1"
    cat <<SURVIVALK_DEFAUL_RECIPE
###############################################################################
# KHA Survival Kit Recipe: '${recipeName}
###############################################################################
# This is a BASH script recipe.

#######################################
# Pack some tools:
ksk-pack "\${KHA_PATH}" '/bin'

SURVIVALK_DEFAUL_RECIPE
}

#######################################
#survivalK-defaultConfig () {
#    cat <<SURVIVALK_DEFAULT_CONFIG
#SURVIVALK_DEFAULT_CONFIG
#}

###############################################################################
# KHA survival-kit plugin Kontext:
###############################################################################

#######################################
ksk-openEnv () {
    KSK_CONFIG="${KHA_ETC_PATH}/${KSKKTX_CONFIG_NAME}"
}

#######################################
ksk-defConfEnv () { : ; }

#######################################
ksk-postConfEnv () {
    KSK_RECIPES_DIR="${KSK_RECIPES_DIR:-${KHA_VAR_PATH}/${KSKKTX_RECIPES_DIR_NAME}}"
}

#######################################
ksk-shutEnv () {
    unset \
        KSK_CONFIG KSK_RECIPES_DIR
}

#######################################
ksk-loadConf () {
    [[ -f "$KSK_CONFIG" ]] || kha-error "Survival Kit's configuration not found !"
    ksk-defConfEnv
    source "$KSK_CONFIG"|| kha-error "Failed to load Survival Kit's configuration !"
    ksk-postConfEnv
}

#######################################
ksk-loadEnv () {
    ksk-openEnv
    ksk-loadConf
}

#######################################
ksk-setupEnv () {
    ksk-openEnv

    if ! [[ -f "$KSK_CONFIG" ]] ; then
        ksk-defaultConfig >"$KSK_CONFIG"
    fi

    kha-edit "$KSK_CONFIG"

    ksk-shutEnv
}

#######################################
ksk-exeK () {
    local cmd="$1" retVal=0 ; shift
    ksk-loadEnv
    "$cmd" "$@" || retVal=$?
    ksk-shutEnv
    return $retVal
}

#######################################
ksk-ktx-exeK () { ktx-exeK ksk-exeK "$@" ; }

###############################################################################
# KHA survival-kit recipes:
###############################################################################

#######################################
ksk-genCook () {
    local recipeName="$1" recipePath="$2" collectRoot="$3" tgtDir="$4"
    local packPath="${tgtDir}/${recipeName}.tbz2"
    cat <<SURVIVAL_COOK_HEADER
#!${LU_BASH}
###############################################################################
# KSK Cook for recipe '${recipeName}'
###############################################################################
set -Cue
###############################################################################
#KHA Environment:
readonly KHA_PATH='${KHA_PATH}'
#Kitchen Environment:
readonly KSK_RECIPES_ROOT='${KSK_RECIPES_DIR}'
readonly KSK_COLLECT_ROOT='${collectRoot}'
###############################################################################
#Kitchen Tools:
#######################################
ksk-error () { echo "Error:" "\$@" >&2 ; exit 1 ; }
ksk-echo () { echo "\$@" >&2 ; }
#######################################
ksk-redirect () { cat >"\${KSK_COLLECT_ROOT}\${1}" ; }
#######################################
ksk-chmod () {
    local mod="\$1" tgt="\${KSK_COLLECT_ROOT}\${2}"
    if [[ -d "\$tgt" ]] ; then chmod -R "\$mod" "\$tgt"
    elif [[ -f "\$tgt" ]] ; then chmod "\$mod" "\$tgt"
    else ksk-error "Unknown target '\${2}' !"
    fi
}
#######################################
ksk-packFile () {
    local src="\$1" tgt="\$2"
    cp "\$src" "\$tgt"
}
#######################################
ksk-packDir () {
    local src="\$1" tgt="\$2"
    local srcName="\$(basename "\$src")"
    ( cd "\$src" && find -L . -type f ) \\
        | cut -b3- | grep -v -e '^ *\$' -e '~$' -e '.old$' | while IFS= read srcFile ; do
        srcPath="\${src}/\${srcFile}"
        tgtPath="\${tgt}/\${srcName}/\${srcFile}"
        tgtDir="\$(dirname "\$tgtPath")"
        if ! [[ -d "\$tgtDir" ]] ; then
            [[ ! -e "\$tgtDir" ]] \\
                || ksk-error "Can't clobber target file: '\${tgtDir}"
            mkdir -p "\$tgtDir" \\
                || ksk-error "Can't create directory: '\${tgtDir}"
        fi
        cp "\$srcPath" "\$tgtPath"
    done
}
#######################################
ksk-pack () {
    local src="\$1" tgt="\${KSK_COLLECT_ROOT}\${2}"
#    ksk-echo " * Packing '\$src' into '\$tgt'..."
    #Check if target directory is present:
    mkdir -p "\$tgt"
    # Avoid clobber:
    local tgtPath="\${tgt}/\$(basename "\$src")"
    [[ ! -e "\$tgtPath" ]] \\
        || ksk-error "Can't clobber target: '\${tgtPath}'"
    #And now launch the right packer....
    if [[ -f "\$src" ]] ; then ksk-packFile "\$src" "\$tgt"
    elif  [[ -d "\$src" ]] ; then ksk-packDir "\$src" "\$tgt"
    else ksk-error "Unknown source type: '\$src'"
    fi
}
###############################################################################
#Reset collecting directory:
[[ ! -d "\$KSK_COLLECT_ROOT" ]] || rm -r "\$KSK_COLLECT_ROOT" \\
    || ksk-error "Unable to clean the collecting directory !"
mkdir -p "\$KSK_COLLECT_ROOT" \\
    || ksk-error "Unable to create the collecting directory !"
###############################################################################
#Launch the collector:
ksk-echo ' * Collecting equipment...'
source '$recipePath' || ksk-error "Failed reading the recipe !"
###############################################################################
#Now we can bake the dish:
ksk-echo ' * Packing stuff...'
#Prepare packing directory:
[[ -d '${tgtDir}' ]] \\
    || mkdir -p '${tgtDir}' \\
    || ksk-error 'Failed to create: ${tgtDir}'
#And pack the stuff !
cd "\$KSK_COLLECT_ROOT" \\
    && tar -cjf '${packPath}' . \\
    || ksk-error 'Failed to create package archive !'
ksk-echo ' * Packing done. Package stored at:'
ksk-echo '${packPath}'
SURVIVAL_COOK_HEADER
}

#######################################
ksk-makeRecipe () {
    # Load arguments:
    local recipePath="$1" recipeDir recipeName tgtDir="$2"
    recipeDir="$(cd "$(dirname "$recipePath")" && pwd)"
    recipeName="$(basename "$recipePath")"
    # Check target directory:
    local absTgt
    absTgt="$(kha-mkAbsDir "${KHA_LAUNCH_DIR}" "$tgtDir")"
    if [[ -e "$absTgt" ]] ; then
        [[ -d "$absTgt" ]] \
            || kha-error "Specified target not a directory: '$absTgt'"
    fi
    # Spawn the cook:
    local cook cookingTable
    cook="$(kha-mktemp)"
    cookingTable="$(kha-mktemp -d)"
    ksk-genCook "$recipeName" "$recipePath" "$cookingTable" "$absTgt" >>"$cook"
    chmod +x "$cook"
    # Review cook process:
#    kha-edit "$cook"
    # Cook it !
    "$cook" || kha-error "Failed to cook the recipe !"
}

###############################################################################
# KHA survival-kit plugin library:
###############################################################################

#######################################
ksk-listRecipes () {
    if [[ -d "$KSK_RECIPES_DIR" ]] ; then
        ( cd "$KSK_RECIPES_DIR" && find -L . -type f -maxdepth 1 2>/dev/null ) \
            | cut -b3- | grep -v -e '^ *$' -e '~$' -e '.old$'
    fi
}

#######################################
ksk-newRecipe () {
    # Load arguments:
    local recipeName="${1:-}"
    [[ -n "$recipeName" ]] || kha-error "Using: ... <Recipe Name> !"
    # Build recipe's data:
    local recipePath="${KSK_RECIPES_DIR}/${recipeName}"
    [[ ! -e "$recipePath" ]] || kha-error "A recipe already exits with this name !"
    # Generate the default recipe:
    kha-ensureDir "$KSK_RECIPES_DIR" 
    ksk-defaultRecipe "$recipeName" >"$recipePath"
    # Give user a first chance to edit it:
    kha-edit "$recipePath"
}

#######################################
ksk-editRecipe () {
    # Load arguments:
    local recipeName="${1:-}"
    [[ -n "$recipeName" ]] || kha-error "Using: ... <Recipe Name> !"
    # Build recipe's data:
    local recipePath="${KSK_RECIPES_DIR}/${recipeName}"
    [[ -f "$recipePath" ]] || kha-error "Unknown recipe !"
    # Edit it:
    kha-edit "$recipePath"
}

#######################################
ksk-pack () {
    # Load arguments:
    local recipeName="${1:-}" tgtDir="${2:-.}"
    [[ -n "$recipeName" ]] || kha-error "Using: ... <Recipe Name> [<Target Directory>] !"
    # Build recipe's data:
    local recipePath="${KSK_RECIPES_DIR}/${recipeName}"
    [[ -f "$recipePath" ]] || kha-error "Unknown recipe !"
    # Make the recipe:
    ksk-makeRecipe "$recipePath" "$tgtDir"
}

###############################################################################
# KHA survival-kit Command Line Interface:
###############################################################################
# Kommands accessible directly as KHA's kommands on the CLI.

#######################################
kmd-setup-survival () { ktx-exeK ksk-setupEnv ; }

#######################################
kmd-sk-list-recipes () { ksk-ktx-exeK ksk-listRecipes ; }
kmd-sk-new-recipe () { ksk-ktx-exeK ksk-newRecipe "$@" ; }
kmd-sk-edit-recipe () { ksk-ktx-exeK ksk-editRecipe "$@" ; }
kmd-sk-pack () { ksk-ktx-exeK ksk-pack "$@" ; }

###############################################################################
# KHA survival-kit plugin initialization:
###############################################################################
