FROM ghcr.io/yitzchak/archlinux-makepkg:latest

ARG ALLEGRO_VERSION=11.0express
ARG ALLEGRO_SHA512=52fded5014b5c60774874067d3a1059fdc403e4e8e5f73163a9215034e0245c584c418cf1535317e2ecdd74e95869a18fbd3f18842d11a97de48567de61b1198

RUN sudo pacman-key --init && \
    echo -e "[multilib]\nInclude = /etc/pacman.d/mirrorlist" | sudo tee --append /etc/pacman.conf && \
    sudo pacman -Syu --noconfirm cmucl sbcl lib32-gcc-libs && \
    sudo bash -c "$(curl -fsSL https://www.thirdlaw.tech/pkg/clasp.sh)"

RUN git clone https://aur.archlinux.org/ccl.git && \
    cd ccl && \
    makepkg --noconfirm --syncdeps --install --nocheck && \
    cd .. && \
    rm -rf ccl

RUN git clone https://aur.archlinux.org/clisp-git.git && \
    cd clisp-git && \
    makepkg --noconfirm --syncdeps --install --nocheck && \
    cd .. && \
    rm -rf clisp-git

RUN git clone https://aur.archlinux.org/abcl-git.git && \
    cd abcl-git && \
    makepkg --noconfirm --syncdeps --install --nocheck && \
    cd .. && \
    rm -rf abcl-git

RUN git clone https://aur.archlinux.org/mkcl-git.git && \
    cd mkcl-git && \
    makepkg --noconfirm --syncdeps --install --nocheck && \
    cd .. && \
    rm -rf mkcl-git

RUN git clone https://aur.archlinux.org/ecl-git.git && \
    cd ecl-git && \
    makepkg --noconfirm --syncdeps --install --nocheck && \
    cd .. && \
    rm -rf ecl-git

RUN curl -fsSL "https://franz.com/ftp/pub/acl${ALLEGRO_VERSION}/linuxamd64.64/acl${ALLEGRO_VERSION}-linux-x64.tbz2" > "acl${ALLEGRO_VERSION}-linux-x64.tbz2" && \
    echo "$ALLEGRO_SHA512  acl${ALLEGRO_VERSION}-linux-x64.tbz2" | sha512sum -c - && \
    sudo tar -C /opt/ -xvf "acl${ALLEGRO_VERSION}-linux-x64.tbz2" && \
    rm "acl${ALLEGRO_VERSION}-linux-x64.tbz2" && \
    sudo /opt/acl${ALLEGRO_VERSION}.64/update.sh -u && \
    sudo ln -s /opt/acl${ALLEGRO_VERSION}.64/alisp /usr/local/bin/alisp

USER root
WORKDIR /root

ENV XDG_CONFIG_HOME=/root/.config
ENV XDG_DATA_HOME=/root/.local/share
ENV XDG_CACHE_HOME=/root/.cache

RUN curl -kLO https://beta.quicklisp.org/quicklisp.lisp && \
    sbcl --non-interactive --load quicklisp.lisp --eval "(quicklisp-quickstart:install)" --eval "(ql-util:without-prompting (ql:add-to-init-file))" && \
    abcl --load ~/quicklisp/setup.lisp --eval "(ql-util:without-prompting (ql:add-to-init-file))" --eval "(ext:quit)" && \
    ccl --load ~/quicklisp/setup.lisp --eval "(ql-util:without-prompting (ql:add-to-init-file))" --eval "(quit)" && \
    clasp --non-interactive --load ~/quicklisp/setup.lisp --eval "(ql-util:without-prompting (ql:add-to-init-file))" && \
    clisp -i ~/quicklisp/setup.lisp -x "(ql-util:without-prompting (ql:add-to-init-file))" && \
    cmucl -load ~/quicklisp/setup.lisp -eval "(ql-util:without-prompting (ql:add-to-init-file))" --eval "(quit)" && \
    ecl --load ~/quicklisp/setup.lisp --eval "(ql-util:without-prompting (ql:add-to-init-file))" --eval "(ext:quit)" && \
    mkcl -load ~/quicklisp/setup.lisp -eval "(ql-util:without-prompting (ql:add-to-init-file))" -eval "(quit)" && \
    alisp --batch -L ~/quicklisp/setup.lisp -e "(ql-util:without-prompting (ql:add-to-init-file))" -e "(excl:exit 0 :quiet t :no-unwind t)" && \
    rm quicklisp.lisp && \
    mkdir -p ~/.config/common-lisp/source-registry.conf.d

COPY asdf-add /usr/local/bin/asdf-add
COPY make-rc /usr/local/bin/make-rc
COPY lisp /usr/local/bin/lisp
