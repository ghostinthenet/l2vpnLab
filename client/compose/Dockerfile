FROM debian:trixie-slim

ENV DEBIAN_FRONTEND=noninteractive

ARG CT_USER
ARG CT_PASSWD

COPY environment /etc/environment
COPY WinBox /home/${CT_USER}/WinBox
COPY winbox.sh /home/${CT_USER}/winbox.sh

RUN apt update
RUN apt install -y --no-install-recommends curl \
      dhcpcd \
      inetutils-ping \
      iproute2 \
      libxkbcommon-x11-0 \
      libxcb-icccm4 \
      libxcb-image0 \
      libxcb-keysyms1 \
      libxcb-render-util0 \
      openssh-server \
      xorg
RUN apt clean
RUN rm -rf /var/lib/apt/lists
RUN echo ${CT_PASSWD} | passwd --stdin root
RUN useradd -m ${CT_USER} -k /etc/skel -s /bin/bash
RUN echo ${CT_PASSWD} | passwd --stdin ${CT_USER}
RUN mkdir -p /home/${CT_USER}/.local/share/MikroTik/WinBox

COPY settings.cfg.viw2 /home/${CT_USER}/.local/share/MikroTik/WinBox/settings.cfg.viw2

RUN chown -R ${CT_USER}:${CT_USER} /home/${CT_USER}

EXPOSE 22

ENTRYPOINT service ssh start && bash 
