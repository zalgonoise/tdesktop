FROM  kcubeterm/termux:latest

# rebuild repo structure as if `tdesktop` was downloaded to ${HOME}
WORKDIR /data/data/com.termux/files/home/tdesktop/cmd
COPY cmd/ ./
WORKDIR /data/data/com.termux/files/home/tdesktop/installers
COPY installers/ ./
WORKDIR /data/data/com.termux/files/home/tdesktop
COPY  setup_tde.sh ./

ARG VNCPASSWD

RUN /data/data/com.termux/files/home/tdesktop/setup_tde.sh install openbox

ENTRYPOINT [ "/data/data/com.termux/files/home/.local/bin/tde" ]
