FROM ubuntu:eoan

RUN dpkg --add-architecture i386

RUN apt-get update -y

RUN apt-get install -y --no-install-recommends winetricks xvfb openssh-server inotify-tools x11vnc ca-certificates cabextract net-tools

RUN apt-get install -y --install-recommends wine-stable wine32

RUN rm -rf /var/lib/apt/lists/*

EXPOSE 5900

COPY entrypoint.sh /usr/local/bin/

RUN chmod 755 /usr/local/bin/entrypoint.sh

RUN useradd -ms /bin/bash aoc

USER aoc

ENV INSTALL /home/aoc
ENV WINEPREFIX $INSTALL/wine
ENV WINEARCH win32
ENV DISPLAY :0.0
ENV MSPATH $WINEPREFIX/drive_c/Program Files (x86)/Microsoft Games
ENV AOCPATH $MSPATH/Age of Empires II
ENV WKPATH $AOCPATH/Games/WololoKingdoms

WORKDIR $INSTALL

RUN wineboot -u && winetricks directplay

COPY registry_update.reg $INSTALL

RUN mkdir -p "$MSPATH"

RUN ln -s /aoc "$AOCPATH"

ENTRYPOINT ["entrypoint.sh"]
