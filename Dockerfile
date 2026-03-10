FROM ghcr.io/yitzchak/archlinux-makepkg:latest

RUN sudo pacman-key --init && \
    echo -e "[multilib]\nInclude = /etc/pacman.d/mirrorlist" | sudo tee --append /etc/pacman.conf && \
    sudo pacman -Syu --noconfirm cmucl ecl sbcl ocicl clisp lib32-gcc-libs 

RUN git clone https://aur.archlinux.org/clasp-cl-git.git && \
    cd clasp-cl-git && \
    makepkg --noconfirm --syncdeps --install --nocheck && \
    cd .. && \
    rm -rf clasp-cl-git

RUN git clone https://aur.archlinux.org/ccl.git && \
    cd ccl && \
    makepkg --noconfirm --syncdeps --install --nocheck && \
    cd .. && \
    rm -rf ccl

RUN git clone https://aur.archlinux.org/abcl-git.git && \
    cd abcl-git && \
    makepkg --noconfirm --syncdeps --install --nocheck && \
    cd .. && \
    rm -rf abcl-git

USER root
WORKDIR /root

ENV XDG_CONFIG_HOME=/root/.config
ENV XDG_DATA_HOME=/root/.local/share
ENV XDG_CACHE_HOME=/root/.cache

RUN ocicl setup 

COPY asdf-add /usr/local/bin/asdf-add
COPY make-rc /usr/local/bin/make-rc
COPY lisp /usr/local/bin/lisp
