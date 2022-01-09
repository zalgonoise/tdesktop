#!/data/data/com.termux/files/usr/bin/bash

# default "need to login" variable
relog=0

baseTools=(
    "git"
)

affectedPackages=(
    "xfce4"
    "tigervnc"
    "qterminal"
    "netsurf"
    "vim" 
    "tmux"
)

verificationCmd=(
    "xfce4-session"
    "vncserver"
    "qterminal"
    "netsurf"
    "vim"
    "tmux"
)

# default echo function
function say() {
    echo -e "[tde]\t$*"

}

# default error function
function err() {
    echo -e "-----\n[tde][ERROR]\t$*\n-----"
    exit 1
}

# default warn function
function warn() {
    echo -e "-----\n[tde][WARN]\t$*\n-----"
}

# default run script function
function run() {
    say "installing ${1}"
    {
        (./installers/${2}) ;
    } && {
        say "${1} installed successfully"
    } || {
        warn "failed to install ${1}"
    }
}

# check and install base tools (if not yet installed)
function checkBaseTools() {
    for tool in ${baseTools[@]}; do
        say "checking if ${tool} is installed"
        if [[ -z $(command -v ${tool}) ]]; then
            say "git isn't installed -- installing ${tool}"
            apt update -y 
            apt install ${tool} -y
        fi
        say "${tool} is installed"
    done
}

# default usage function
function printUsage() {
    usage="\n================================\n"
    usage+="[tdesktop]\n"
    usage+="================================\n"
    usage+="Quick and easy deployment of a\n"
    usage+="desktop environment in Termux.\n"
    usage+="================================\n"
    usage+="  Command flags:\n"
    usage+="$ ./tdesktop [install|uninstall]\n"
    usage+="    |--> install: prepares a new\n"
    usage+="    |    deployment, with select\n"
    usage+="    |    targets.\n"
    usage+="    |    \n"
    usage+="    +--> uninstall: removes all \n"
    usage+="         packages that this \n"
    usage+="         script installed, while\n"
    usage+="         preserving user configs\n"
    usage+="--------------------------------\n"
    usage+="$ (...) install [desktop | shell\n"
    usage+="    |       extras | all]\n"
    usage+="    |--> desktop: sets up only  \n"
    usage+="    |    the required packages  \n"
    usage+="    |    for running XFCE       \n"
    usage+="    |--> shell: sets up zsh,    \n"
    usage+="    |    oh-my-zsh, and p10k    \n"
    usage+="    |--> extras: sets up awesome\n"
    usage+="    |    vim and awesome tmux   \n"
    usage+="    +--> all: all of the above  \n"
    usage+="================================\n\n"

    echo -e ${usage}
}

# default installation target
function installTDE() {
    opts=$@

    getDesktop=0
    getShell=0
    getExtras=0
    getAll=0

    for i in ${opts}; do
        if [[ ${i} == "all" ]]; then
            say "set to install all packages"
            getAll=1
        fi
        if [[ ${i} == "desktop" ]]; then
            say "set to install desktop packages"
            getDesktop=1
        fi
        if [[ ${i} == "shell" ]]; then
            say "set to install shell packages"
            getShell=1
        fi
        if [[ ${i} == "extras" ]]; then
            say "set to install extra packages"
            getExtras=1
        fi
    done

    checkBaseTools

    if [[ ${getAll} == 0 ]]; then
        if [[ ${getDesktop} == 0 ]] \
        && [[ ${getShell} == 0 ]] \
        && [[ ${getExtras} == 0 ]]; then
            err "no options selected"
        fi

        if [[ ${getDesktop} == 1 ]]; then
            run "desktop" "setup_desktop.sh"
        fi

        if [[ ${getShell} == 1 ]]; then
            run "shell" "setup_shell.sh"
        fi

        if [[ ${getExtras} == 1 ]]; then
            run "extras" "setup_extras.sh"
        fi
    elif [[ ${getAll} == 1 ]]; then
        run "desktop" "setup_desktop.sh" \
        && run "shell" "setup_shell.sh" \
        && run "extras" "setup_extras.sh"
    fi 

    if [[ ${getAll} == 1 ]] \
    || [[ ${getDesktop} == 1 ]] \
    || [[ ${getShell} == 1 ]]; then
        relog=1
    fi

}

# default uninstallation target
function uninstallTDE() {
    say "uninstalling packages -- config files and shell will be preserved"
    {
        for (( i=0 ; i <${#affectedPackages[@]} ; i++ )); do
            if ! [[ -z $(command -v ${verificationCmd[i]}) ]]; then
                apt remove ${affectedPackages[i]} -y \
                && apt clean -y \
                && apt autoremove  -y;
            fi
        done
    } && {
        say "packages uninstalled successfully"
    } || {
        err "unable to remove target packages"
    }

}

# default enums
optionEnum=(
    "install"
    "uninstall"
)
paramEnum=(
    "desktop"
    "extras"
    "shell"
    "all"
)

# Check working directory, for installation folder
pwd=$(pwd)
say "saving current path: ${pwd}"
{
    installFile=$(realpath $0)
} || {
    err "failed to find installation folder" ;
}
installPath=${installFile//setup_tde.sh/}
cd ${installPath}
say "changed to install path: ${installPath}"


# Capture user input
option=${1:-"none"}
parameter=( $@ )

# upon "install" or "uninstall", the remainder of the args are passed
# to the corresponding function (installTDE / uninstallTDE); otherwise
# exits with an error (or just prints usage)
if [[ ${option} == "none" ]]; then
    printUsage
    cd ${pwd}
    exit 0
elif [[ ${option} == "install" ]]; then
    installTDE ${parameter[@]:1:4}
    cd ${pwd}
    if [[ ${relog} == 1 ]]; then
        say "shell changed; reloading termux"
        ${PREFIX}/bin/login
    else 
        exit 0
    fi
elif [[ ${option} == "uninstall" ]]; then
    uninstallTDE ${parameter[@]:1:4}
    cd ${pwd}
    exit 0
else 
    warn "invalid option"
    printUsage
    cd ${pwd}
    exit 1
fi