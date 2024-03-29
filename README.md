# tdesktop

__________________

_Easily setup a desktop environment in Termux, to have a GUI over VNC._



___________________

### BETA

__Setup instructions__

1. Clone this repo using `git` (or `curl`, or `wget`):

```
git clone https://github.com/ZalgoNoise/tdesktop
```

2. Launch the installer, picking the module that you wish to install:

  - `desktop`: installs desktop environment packages and configs
  - `shell`: installs zsh, oh-my-zsh and p10k
  - `extras`: installs awesome vim and awesome tmux
  - `all`: installs all of the above 

```
# considering you are at $HOME, or ~/ (any location is fine)
./tdesktop/setup_tde.sh install all
```

> Note that installing desktop packages will involve VNC prompting you for a password

3. Once the setup is completed, you may need to setup your p10k config. Follow these steps carefully or do it later with `p10k configure`

4. (if installed) Launch a new VNC server with:

```
tde
```

___________________________________

__Removal instructions__


1. Execute the same setup script, with the uninstall option instead:

```
# considering you are at $HOME, or ~/ (any location is fine)
./tdesktop/setup_tde.sh uninstall
```


> Note: work-in-progress; although functional, this repo will suffer changes in the near future.


____________________________________

__Non-interactive installation__

You're able to install a desktop environment in one-shot by defining a environment variable for your VNC password (as `VNCPASSWD`) and targetting a specific (supported) desktop environment, as such:

```
VNCPASSWD=tdesktop ./tdesktop/setup_tde.sh install openbox
```

This command will run the installation script __without__ prompting you for a VNC password (it takes the one set in `VNCPASSWD`) and will not prompt you to pick a desktop environment. The installation process will run on its own from start to finish, logging all progress and any errors. 
