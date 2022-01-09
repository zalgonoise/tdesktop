#!/data/data/com.termux/files/usr/bin/bash

sensitiveFiles=(
    ".vim_runtime"      # awesome vim config folder
    ".vimrc"            # vim rc file
    ".tmux"             # tmux config folder
    ".tmux.conf"        # tmux symlinked config file
    ".tmux.conf.local"  # tmux rc file
)

packageList=(
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

function backup() {
    array=( $@ )

    mkdir -p ${HOME}/.backup
    for (( i=0 ; i<${#array[@]} ; i++ )); do
        if [[ -f ${array[i]} ]]; then
            src=$(find ${HOME} -maxdepth 1 -name ${array[i]})
            dest=$(echo ${src} | sed 's/'${HOME//\//\\\/}'/'${HOME//\//\\\/}'\/\.backup/g')
            cp -r ${src} ${dest}
        fi

    done
}

# non-destructive backup before initializing
say "backing up existing rc files"
pwd=$(pwd)
if [[ ${pwd} != ${HOME} ]]; then
    cd ${HOME}
fi
{
    backup ${sensitiveFiles[@]} ;
} && {
    say "backup successful (to ~/.backup)" ;
} || {
    warn "failed to backup files" ;
}

# installing packages
say "installing required packages: ${packageList[@]}"
{
    apt install -y ${packageList[@]};
} && {
    say "packages installed successfully: ${packageList[@]}" ;
} || {
    err "failed to install packages: ${packageList[@]}" ;
}

# installing awesome vim
if ! [[ -d ${HOME}/.vim_runtime ]]; then
    say "getting awesome vim"
    {
        git clone --depth=1 https://github.com/amix/vimrc.git ${HOME}/.vim_runtime ;
    } && {
        say "fetched awesome vim" \
        && say "setting up awesome vim" \
        && {
            (sh ~/.vim_runtime/install_awesome_vimrc.sh) ;
        } && {
            say "awesome vim set up successfully" ;
        } || {
            err "failed to setup awesome vim" ;
        }
    } || {
        err "failed to get awesome vim" ;
    }
fi

# installing awesome tmux
if ! [[ -d ${HOME}/.tmux ]]; then
    say "installing awesome tmux"
    {
        git clone https://github.com/gpakosz/.tmux.git ${HOME}/.tmux ;
    } && {
        say "fetched awesome tmux" \
        && say "setting up awesome tmux" \
        && {
            ln -s -f ${HOME}/.tmux/.tmux.conf ${HOME}/.tmux.conf
            cp ${HOME}/.tmux/.tmux.conf.local ${HOME}/.
        } && {
            say "awesome tmux set up successfully" ;
        } || {
            err "failed to setup awesome tmux" ;
        }
    } || {
        err "failed to get awesome tmux" ;
    }
fi

# setting up termux storage
say "setting up termux storage"
{
    apt install -y termux-api ; 
} && {
    say "termux-api installed successfully" \
    && say "setting up termux storage" \
    && {
        termux-setup-storage ;
    } && {
        say "termux storage is available in ~/storage" ;
    } || {
        warn "error occurred when running $ termux-setup-storage"
    }
} || {
    warn "failed to install termux-api"
}

# return to pdw
cd ${pwd}