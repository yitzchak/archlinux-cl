FROM ghcr.io/yitzchak/archlinux-makepkg:latest

ARG ALLEGRO_VERSION=10.1express
ARG ALLEGRO_SHA512=045cb7946a9876807541d28097c4bb875c2dacd9ac20c841b7bcd6deec4101c7569f454eff80b2d8a74bd9ee255bf68ce14aaf0053d97e095f7e49499df80707

ENV PATH="~/.local/bin:$PATH"

RUN sudo pacman-key --init && \
    echo -e "[multilib]\nInclude = /etc/pacman.d/mirrorlist" | sudo tee --append /etc/pacman.conf && \
    sudo pacman -Syu --noconfirm cmucl ecl sbcl lib32-gcc-libs && \
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

RUN git clone https://aur.archlinux.org/abcl.git && \
    cd abcl && \
    makepkg --noconfirm --syncdeps --install --nocheck && \
    cd .. && \
    rm -rf abcl

RUN git clone https://aur.archlinux.org/mkcl-git.git && \
    cd mkcl-git && \
    makepkg --noconfirm --syncdeps --install --nocheck && \
    cd .. && \
    rm -rf mkcl-git

RUN curl -fsSL "https://franz.com/ftp/pub/acl${ALLEGRO_VERSION}/linuxamd64.64/acl${ALLEGRO_VERSION}-linux-x64.tbz2" > "acl${ALLEGRO_VERSION}-linux-x64.tbz2" && \
    echo "$ALLEGRO_SHA512  acl${ALLEGRO_VERSION}-linux-x64.tbz2" | sha512sum -c - && \
    sudo tar -C /opt/ -xvf "acl${ALLEGRO_VERSION}-linux-x64.tbz2" && \
    rm "acl${ALLEGRO_VERSION}-linux-x64.tbz2" && \
    sudo /opt/acl${ALLEGRO_VERSION}.64/update.sh -u && \
    sudo ln -s /opt/acl${ALLEGRO_VERSION}.64/alisp /usr/local/bin/alisp

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

COPY asdf-add .local/bin/asdf-add