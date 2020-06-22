#!/usr/bin/env zsh

# `jv` is a tiny script for quickly changing the default JVM version.
#
# Example usage:
# $ source ./jv.zsh 14
#
# Add a symlink for convenience's sake:
# $ ln -s "$(pwd)/jv.zsh" /usr/local/bin/jv
# And use the script from anywhere:
# $ . jv 14
#
# NOTE: For the `export` statement to work in the parent Shell, the script must
# be `source`'d rather than ran in the common way.
#
# Since the script is expected to be executed in the current Shell, using the
# `exit` instruction would close the current instance, which is undesirable.
# That is why the script has a peculiar structure -- the lack of `goto`
# statement support results in ugly nesting of if-statements.

declare -A JDK_VERSION_DISAMBIGUATIONS=(
    5 "1.5"
    6 "1.6"
    7 "1.7"
    8 "1.8"
)
declare -A TXT=(
    red "$(tput setaf 1)"
    green "$(tput setaf 2)"
    yellow "$(tput setaf 3)"
    bold "$(tput bold)"
    reset "$(tput sgr0)"
)

SUPPLIED_VERSION="$1"

# Displays usage instructions.
function usage() {
    echo -e "${TXT[bold]}Usage:${TXT[reset]}"
    echo -e "$ jv <${TXT[yellow]}${TXT[bold]}jdk_version${TXT[reset]}>"
}

# Prints the given error message and exits with the given exit code.
# @param $1 error message
function raise_error() {
    echo -e "${TXT[red]}${TXT[bold]}ERROR: ${TXT[reset]}${TXT[red]}${1}${TXT[reset]}\n"
    usage
}

if [[ -z "$SUPPLIED_VERSION" ]]; then
    raise_error "No JDK version was given in the first argument."
else
    if [[ -n $JDK_VERSION_DISAMBIGUATIONS[$SUPPLIED_VERSION] ]]; then
        version="$JDK_VERSION_DISAMBIGUATIONS[$SUPPLIED_VERSION]"
    else
        version="$SUPPLIED_VERSION"
    fi

    /usr/libexec/java_home -v "$version" >/dev/null 2>&1
    if [[ $? == 0 ]]; then
        JAVA_HOME="$(/usr/libexec/java_home -v "$version")"
        export JAVA_HOME
        echo "${TXT[bold]}${TXT[green]}\$JAVA_HOME is now set to the following path:${TXT[reset]}"
        echo "$JAVA_HOME"
    else
        raise_error "Unable to find any JVMs matching version ${version}."
    fi
fi
