#!/data/data/com.termux/files/usr/bin/bash

sensitiveFiles=(
    ".zshrc"        # zsh rc file
    ".zsh_history"  # zsh history file
    ".oh-my-zsh"    # oh-my-zsh extras folder
)

packageList=(
    "zsh"
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


# get zsh
say "installing ${packageList[@]}"
{
    apt install -y ${packageList[@]} ;
} && {
    say "packages installed successfully: ${packageList[@]}" ;
} || {
    err "failed to install ${packageList[@]}" ;
}

# change shell to zsh
#
# adding conditional in /etc/termux-login.sh to ensure SHELL is zsh
say "changing shell to zsh"
{
    chsh -s zsh ${USER}
} && {
    say "changed shell to zsh successfully" ;
} || {
    err "unable to change shell to zsh" ;
}

# get oh-my-zsh
if ! [[ -d ${HOME}/.oh-my-zsh ]]; then
    say "getting oh-my-zsh"
    {
        git clone https://github.com/robbyrussell/oh-my-zsh.git ${HOME}/.oh-my-zsh \
        && cp ${HOME}/.oh-my-zsh/templates/zshrc.zsh-template ${HOME}/.zshrc ;
        
    } && {
        say "fetched oh-my-zsh" ;
    } || {
        err "failed to get oh-my-zsh" ;
    }
fi


# get and install oh-my-zsh plugins
say "getting oh-my-zsh plugins"
{
    if ! [[ -d ${HOME}/.oh-my-zsh/plugins/zsh-syntax-highlighting ]]; then
        git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "${HOME}/.oh-my-zsh/plugins/zsh-syntax-highlighting" --depth 1
    fi ;
    if ! [[ -d ${HOME}/.oh-my-zsh/plugins/zsh-completions ]]; then
        git clone https://github.com/zsh-users/zsh-completions.git "${HOME}/.oh-my-zsh/plugins/zsh-completions" --depth 1 
    fi ;
    if ! [[ -d ${HOME}/.oh-my-zsh/plugins/zsh-autosuggestions ]]; then
        git clone https://github.com/zsh-users/zsh-autosuggestions.git "${HOME}/.oh-my-zsh/plugins/zsh-autosuggestions/" --depth 1
    fi ;
} && {
    say "fetched oh-my-zsh plugins" \
    && say "configuring plugins" \
    && {
        if [[ -z $(grep -e "^plugins=(git zsh-syntax-highlighting zsh-completions zsh-autosuggestions)$" ${HOME}/.zshrc) ]]; then
            sed -i 's/^plugins=(.*)/plugins=(git zsh-syntax-highlighting zsh-completions zsh-autosuggestions)/' ${HOME}/.zshrc
        fi
    } && {
        say "plugins configured successfully"
    } || {
        err "failed to configure plugins"
    } ;
} || {
    err "failed to get oh-my-zsh plugins"
}

# get powerlevel10k
say "getting powerlevel10k shell theme"
if ! [[ -d ${ZSH_CUSTOM:-${HOME}/.oh-my-zsh/custom}/themes/powerlevel10k ]]; then
    {
        git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-${HOME}/.oh-my-zsh/custom}/themes/powerlevel10k
    } && {
        say "fetched powerlevel10k successfully";
        if  [[ -z $(grep "ZSH_THEME=\"powerlevel10k/powerlevel10k\"" ${HOME}/.zshrc) ]]; then
            say "configuring powerlevel10k theme" \
            && {
                sed -i 's/ZSH_THEME=".*"/ZSH_THEME="powerlevel10k\/powerlevel10k"/' ${HOME}/.zshrc
            } && {
                say "powerlevel10k configured successfully"
            } || {
                err "failed to configure powerlevel10k"
            }
        fi
    } || {
        err "failed to fetch powerlevel10k"
    }
fi