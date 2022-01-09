#!/data/data/com.termux/files/usr/bin/bash

sensitiveFiles=(
    ".vnc"          # vnc server config folder
    ".config"       # .config folder for desktop apps
)

#TODO: DE options (xfce, openbox, etc)
packageList=(
    "xfce4"         
    "tigervnc"
    "qterminal"
    "netsurf"
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
# TODO: add options for different DEs
say "installing VNC server and GUI tools"
{
    apt install -y ${packageList[@]} ;
} && {
    say "packages installed successfully: ${packageList[@]}" ;
} || {
    err "failed to install packages: ${packageList[@]}" ;
}

# setup VNC server
say "first-time setup for VNC; enter a password when prompted"
vncserver -localhost # asks for password to setup
vncserver -kill :1

# prepare VNC startup script 
cat << EOF > ${HOME}/.vnc/xstartup
#!/data/data/com.termux/files/usr/bin/sh
## This file is executed during VNC server
## startup.

xrdb ${HOME}/.Xresourcesw
xfce4-session & 
EOF
chmod +x ${HOME}/.vnc/xstartup
say "vnc service is configured"

# setting up qterminal config
say "setting up qterminal config"
{
    mkdir -p ${HOME}/.config/qterminal \
    && cat << EOF > ${HOME}/.config/qterminal/qterminal.ini
[General]
AskOnExit=true
BoldIntense=true
BookmarksFile=/data/data/com.termux/files/home/.config/qterminal.org/qterminal_bookmarks.xml
BookmarksVisible=true
Borderless=false
ChangeWindowIcon=true
ChangeWindowTitle=true
CloseTabOnMiddleClick=true
ConfirmMultilinePaste=false
DisableBracketedPasteMode=false
FixedTabWidth=true
FixedTabWidthValue=500
HandleHistory=
HideTabBarWithOneTab=true
HistoryLimited=true
HistoryLimitedTo=1000
KeyboardCursorShape=0
LastWindowMaximized=false
MenuVisible=true
MotionAfterPaste=2
NoMenubarAccel=true
OpenNewTabRightToActiveTab=false
PrefDialogSize=@Size(700 539)
SavePosOnExit=true
SaveSizeOnExit=true
ScrollbarPosition=2
ShowCloseTabButton=false
TabBarless=true
TabsPosition=0
Term=xterm-256color
TerminalBackgroundImage=
TerminalBackgroundMode=0
TerminalMargin=0
TerminalTransparency=0
TerminalsPreset=0
TrimPastedTrailingNewlines=false
UseBookmarks=false
UseCWD=false
UseFontBoxDrawingChars=false
colorScheme=BreezeModified
emulation=default
enabledBidiSupport=true
fontFamily=Monospace
fontSize=12
guiStyle=
highlightCurrentTerminal=false
showTerminalSizeHint=true
version=0.17.0

[DropMode]
Height=45
KeepOpen=false
ShortCut=F12
ShowOnStart=true
Width=70

[MainWindow]
ApplicationTransparency=25
fixedSize=@Size(600 400)
pos=@Point(47 53)
size=@Size(600 420)
state=@ByteArray(\0\0\0\xff\0\0\0\0\xfd\0\0\0\x1\0\0\0\0\0\0\0\0\0\0\0\0\xfc\x2\0\0\0\x1\xfb\0\0\0&\0\x42\0o\0o\0k\0m\0\x61\0r\0k\0s\0\x44\0o\0\x63\0k\0W\0i\0\x64\0g\0\x65\0t\0\0\0\0\0\xff\xff\xff\xff\0\0\0s\0\xff\xff\xff\0\0\x2X\0\0\x1\x90\0\0\0\x4\0\0\0\x4\0\0\0\b\0\0\0\b\xfc\0\0\0\0)

[Sessions]
size=0

[Shortcuts]
Add%20Tab=Ctrl+Shift+T
Bottom%20Subterminal=Alt+Down
Clear%20Active%20Terminal=Ctrl+Shift+X
Close%20Tab=Ctrl+Shift+W
Collapse%20Subterminal=
Copy%20Selection=Ctrl+Shift+C
Find=Ctrl+Shift+F
Fullscreen=F11
Handle%20history=
Hide%20Window%20Borders=
Left%20Subterminal=Alt+Left
Move%20Tab%20Left=Alt+Shift+Left|Ctrl+Shift+PgUp
Move%20Tab%20Right=Alt+Shift+Right|Ctrl+Shift+PgDown
New%20Window=Ctrl+Shift+N
Next%20Tab=Ctrl+PgDown
Next%20Tab%20in%20History=Ctrl+Shift+Tab
Paste%20Clipboard=Ctrl+Shift+V
Paste%20Selection=Shift+Ins
Preferences...=
Previous%20Tab=Ctrl+PgUp
Previous%20Tab%20in%20History=Ctrl+Tab
Quit=
Rename%20Session=Alt+Shift+S
Right%20Subterminal=Alt+Right
Show%20Tab%20Bar=
Split%20Terminal%20Horizontally=
Split%20Terminal%20Vertically=
Tab%201=
Tab%2010=
Tab%202=
Tab%203=
Tab%204=
Tab%205=
Tab%206=
Tab%207=
Tab%208=
Tab%209=
Toggle%20Bookmarks=Ctrl+Shift+B
Toggle%20Menu=Ctrl+Shift+M
Top%20Subterminal=Alt+Up
Zoom%20in=Ctrl++
Zoom%20out=Ctrl+-
Zoom%20reset=Ctrl+0
EOF
} && {
    say "qterminal setup successfully"
} || {
    warn "unable to configure qterminal -- most likely running defaults"
}

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