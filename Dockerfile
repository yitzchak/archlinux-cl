FROM ghcr.io/yitzchak/archlinux-makepkg:latest

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

RUN curl -kLO https://beta.quicklisp.org/quicklisp.lisp && \
    sbcl --non-interactive --load quicklisp.lisp --eval "(quicklisp-quickstart:install)" --eval "(ql-util:without-prompting (ql:add-to-init-file))" && \
    abcl --batch --load ~/quicklisp/setup.lisp --eval "(ql-util:without-prompting (ql:add-to-init-file))" && \
    ccl --load ~/quicklisp/setup.lisp --eval "(ql-util:without-prompting (ql:add-to-init-file))" --eval "(quit)" && \
    clasp --non-interactive --load ~/quicklisp/setup.lisp --eval "(ql-util:without-prompting (ql:add-to-init-file))" && \
    clisp -i ~/quicklisp/setup.lisp -x "(ql-util:without-prompting (ql:add-to-init-file))" && \
    cmucl -load ~/quicklisp/setup.lisp -eval "(ql-util:without-prompting (ql:add-to-init-file))" --eval "(quit)" && \
    ecl --load ~/quicklisp/setup.lisp --eval "(ql-util:without-prompting (ql:add-to-init-file))" --eval "(ext:quit)" && \
    rm quicklisp.lisp