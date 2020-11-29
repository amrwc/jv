#!/usr/bin/env zsh

# `jv` is a tiny script for quickly changing the default JDK version.
#
# It works under an assumption that there's only one instance of a major
# version installed. E.g. there's only one JDK 11 available.
#
# EXAMPLE USAGE
# $ source ./jv.zsh 14
#
# Add a symlink for convenience:
# $ ln -s "$(pwd)/jv.zsh" /usr/local/bin/jv
# And use the script from anywhere:
# $ . jv 14
#
# NOTES
# - For the `export` statement to work in the parent shell, the script must be
#   sourced rather than ran in the common way.
# - Since the script is expected to be executed in the current Shell, using the
#   `exit` instruction would close the current instance, which is undesirable.
#   That's why the error function doesn't quit the execution, but only prints
#   the error message before the main execution path returns with an error
#   code.
# - Don't use the `readonly` keyword in this script as it's sourced within the
#   current shell process. It means that once a variable is set as `readonly`,
#   it is then tricky to unset it. See the whole thread about it:
#   https://stackoverflow.com/q/17397069/10620237

declare -A JDK_VERSION_DISAMBIGUATIONS=(
    [5]='1.5'
    [6]='1.6'
    [7]='1.7'
    [8]='1.8'
)

# For more colours, see: https://unix.stackexchange.com/a/438357
declare -A TXT_COLOUR=(
    [red]="$(tput setaf 1)"
    [green]="$(tput setaf 2)"
    [yellow]="$(tput setaf 3)"
    [white]="$(tput setaf 15)"
)

declare -A TXT_EFFECT=(
    [bold]="$(tput bold)"
    [reset]="$(tput sgr0)"
)

# Prints the given message in the given colour with an optional effect.
# @param $1 text colour
# @param $2 message
# @param $3 (optional) text effect
function print_coloured() {
    local colour="${TXT_COLOUR[$1]}"
    local effect=''
    if [[ -n "$3" ]]; then
        effect="${TXT_EFFECT[$3]}"
    fi
    printf "%s%s%s%s\n" "$colour" "$effect" "$2" "${TXT_EFFECT[reset]}"
}

# Displays usage instructions.
function usage() {
    print_coloured 'white' 'Usage:'
    print_coloured 'white' '  jv.zsh <jdk_version>'
}

# Prints the given error message and usage instructions.
# @param $1 error message
function print_error() {
    print_coloured 'red' "ERROR: ${1}" 'bold'
    usage
}

##############################################################################
#################################### MAIN ####################################
##############################################################################

supplied_version="$1"

if [[ -z "$supplied_version" ]]; then
    print_error 'No JDK version supplied.'
    return 1
fi

disambiguation="${JDK_VERSION_DISAMBIGUATIONS[$supplied_version]}"
version="$([ -n "$disambiguation" ] && echo "$disambiguation" || echo "$supplied_version")"

if /usr/libexec/java_home -v "$version" >/dev/null 2>&1; then
    JAVA_HOME="$(/usr/libexec/java_home -v "$version")"
    export JAVA_HOME
    print_coloured 'green' '$JAVA_HOME is now set to the following path:'
    print_coloured 'white' "$JAVA_HOME"
else
    print_error "Unable to find any JVMs matching version \"${version}\"."
    return 1
fi
