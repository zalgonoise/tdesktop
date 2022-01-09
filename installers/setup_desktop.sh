#!/data/data/com.termux/files/usr/bin/bash

sensitiveFiles=(
    ".vnc"          # vnc server config folder
    ".config"       # .config folder for desktop apps
)

desktopEnvs=(
    "XFCE"
    "Openbox"
    "LXQt"
    "MATE"
    "Fluxbox"
)

packageList=(
    "tigervnc"
    "xfce4-terminal"
    "netsurf"
    "geany"
    "thunar"
)

desktopEnvPkgs=(
    "xfce4"
    "openbox tint2 rofi python3 feh xfce4-settings polybar ncmpcpp"
    "lxqt"
    "mate-* marco"
    "fluxbox"
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

# default backup function
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


# import openbox styles from https://github.com/adi1090x/termux-desktop
function getOpenboxStyles() {
    mkdir -p ~/.config

    cd ${PREFIX}/tmp ;
    {
        git clone https://github.com/adi1090x/termux-desktop \
        && cd termux-desktop/files ;
    } && {
        say "fetched adi1090x/termux-desktop openbox styles"
    } || {
        err "failed to get adi1090x/termux-desktop openbox styles"
    }

    reqConfig=(
        ".config/geany"
        ".config/gtk-3.0"
        ".config/netsurf"
        ".config/openbox"
        ".config/polybar"
        ".config/rofi"
        ".config/Thunar"
        ".config/xfce4"        
    )

    reqItems=(
        ".fehbg"
        ".fonts"
        ".gtkrc-2.0"
        ".icons"
        ".local"
        ".mpd"
        ".ncmpcpp"
        ".themes"               
    )

    cp -r ${reqItems[@]} ${HOME}/
    cp -r ${reqConfig[@]} ${HOME}/.config/
    cd ${PREFIX}/tmp 
    rm -rf termux-desktop

    cd ${pwd}
    
}

# non-interactive VNC setup
function autoVNC() {
    mkdir -p ${HOME}/.vnc
    echo ${vncPassword} | vncpasswd -f > ${HOME}/.vnc/passwd
    chmod 0600 ${HOME}/.vnc/passwd
}


# initialize input arguments (if any)
if ! [[ ${1} == "none" ]]; then
    desktopMode=${1}
else
    desktopMode=""
fi

if [[ ${2} ]]; then
    vncPassword=${2}
else
    vncPassword=""
fi




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


# update & upgrade before anything else
say "updating base packages"
{
    apt update -y \
    && apt upgrade -y ;
} && {
    say "packages were updated" ;
} || {
    warn "failed to update packages" ;
}

# install X11 repo for GUI packages
say "adding X11 repo"
{
    apt install -y x11-repo ;
} && {
    say "X11 repo added successfully" ;
} || {
    err "failed to add X11 repo" ;
}


# install VNC server, QTerminal and Netsurf
say "installing VNC server and GUI tools"
if [[ -z ${desktopMode} ]]; then
    say "select a desktop environment to install:"

    deOpt=""
    select de in ${desktopEnvs[@]}; do
        case ${de} in
            ${desktopEnvs[0]})                                                         # "XFCE"
                packageList+=(${desktopEnvPkgs[0]}) ; deOpt=${desktopEnvs[0]} ; break ;;
            ${desktopEnvs[1]})                                                         # "Openbox"
                packageList+=(${desktopEnvPkgs[1]}) ; deOpt=${desktopEnvs[1]} ; break ;;
            ${desktopEnvs[2]})                                                         # "LXQt"
                packageList+=(${desktopEnvPkgs[2]}) ; deOpt=${desktopEnvs[2]} ; break ;;
            ${desktopEnvs[3]})                                                         # "MATE"
                packageList+=(${desktopEnvPkgs[3]}) ; deOpt=${desktopEnvs[3]} ; break ;;
            ${desktopEnvs[4]})                                                         # "Fluxbox"
                packageList+=(${desktopEnvPkgs[4]}) ; deOpt=${desktopEnvs[4]} ; break ;;
            *)
                err "invalid option: ${REPLY}" ;;
        esac
    done
else 
    case ${desktopMode} in
        ${desktopEnvs[0]})                                                         # "XFCE"
            packageList+=(${desktopEnvPkgs[0]}) ; deOpt=${desktopEnvs[0]} ; break ;;
        ${desktopEnvs[1]})                                                         # "Openbox"
            packageList+=(${desktopEnvPkgs[1]}) ; deOpt=${desktopEnvs[1]} ; break ;;
        ${desktopEnvs[2]})                                                         # "LXQt"
            packageList+=(${desktopEnvPkgs[2]}) ; deOpt=${desktopEnvs[2]} ; break ;;
        ${desktopEnvs[3]})                                                         # "MATE"
            packageList+=(${desktopEnvPkgs[3]}) ; deOpt=${desktopEnvs[3]} ; break ;;
        ${desktopEnvs[4]})                                                         # "Fluxbox"
            packageList+=(${desktopEnvPkgs[4]}) ; deOpt=${desktopEnvs[4]} ; break ;;
        *)
            err "invalid option: ${desktopMode}" ;;
    esac
fi



{
    apt install -y ${packageList[@]} ;
} && {
    say "packages installed successfully: ${packageList[@]}" ;
} || {
    err "failed to install packages: ${packageList[@]}" ;
}

# setup VNC server
if [[ -z ${vncPassword} ]]; then
    say "first-time setup for VNC; enter a password when prompted"
    vncserver -localhost # asks for password to setup
    vncserver -kill :1
else
    autoVNC
fi

# prepare VNC startup script 
        cat << EOF > ${HOME}/.vnc/xstartup
#!/data/data/com.termux/files/usr/bin/sh
## This file is executed during VNC server
## startup.

EOF

case ${deOpt} in
    ${desktopEnvs[0]})                      # "XFCE"
        say "setting up VNC config for ${desktopEnvs[0]}"
        cat << EOF >> ${HOME}/.vnc/xstartup
xrdb ${HOME}/.Xresourcesw
xfce4-session & 
EOF
        ;;
    ${desktopEnvs[1]})                      # "Openbox"
        say "setting up VNC config for ${desktopEnvs[1]}"
        cat << EOF >> ${HOME}/.vnc/xstartup
openbox-session &
EOF
        getOpenboxStyles 
        ;;
    ${desktopEnvs[2]})                      # "LXQt"
        say "setting up VNC config for ${desktopEnvs[2]}"
        cat << EOF >> ${HOME}/.vnc/xstartup
lxqt-session &
EOF
        ;;
    ${desktopEnvs[3]})                      # "MATE"
        say "setting up VNC config for ${desktopEnvs[3]}"
        cat << EOF >> ${HOME}/.vnc/xstartup
mate-session &
EOF
        ;;
    ${desktopEnvs[4]})                      # "Fluxbox"
        say "setting up VNC config for ${desktopEnvs[4]}"
        cat << EOF >> ${HOME}/.vnc/xstartup
# Generate menu
fluxbox-generate_menu

# Start fluxbox
fluxbox &
EOF
        ;;
esac

chmod +x ${HOME}/.vnc/xstartup
say "vnc service is configured"

# setting up symlinks for executable
say "setting up symlink for the launcher script, on ~/.local/bin"
mkdir -p ${HOME}/.local/bin

# ensure that PATH is visible to all shells, with /etc/profile
if [[ -z $(echo $PATH | grep -e ".*:${HOME}/.local/bin") ]] \
|| [[ -z $(grep -e "PATH=.*:${HOME}/\.local/bin" ${PREFIX}/etc/profile) ]]; then 
    say "adding ~/.local/bin to PATH"
    {
        cp ${PREFIX}/etc/profile ${PREFIX}/tmp/profile
        echo "export PATH=${PATH}:${HOME}/.local/bin" >> ${PREFIX}/tmp/profile
        mv ${PREFIX}/tmp/profile ${PREFIX}/etc/profile
        # manually load this PATH, for this session
        export PATH=${PATH}:${HOME}/.local/bin
    } && {
        say "~/.local/bin added to PATH successfully"
    } || {
        warn "failed to add ~/.local/bin to PATH"
    }

    if ! [[ -f ${HOME}/.local/bin/tde ]]; then 
        say "placing a symlink of tde.sh in ~/.local/bin/tde"
        {
            cd ${pwd}
            chmod +x $(pwd)/cmd/tde
            ln -s -f $(pwd)/cmd/tde ${HOME}/.local/bin/tde
        } && {
            say "symlink created successfully -- you can now run a desktop with $ tde"
        } || {
            warn "failed to symlink executable"
        }
    fi
fi