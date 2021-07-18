FROM archlinux:latest

RUN pacman -Syu --noconfirm base-devel sudo && \
    echo '%wheel ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers && \
    useradd -m -s /bin/bash -G wheel builder

USER builder
WORKDIR /home/builder

# # install aurutils and register it as local package repository
RUN \
    gpg --recv-keys --keyserver pgp.mit.edu 6BC26A17B9B7018A && \
    cd /tmp/ && \
    curl --output aurutils.tar.gz https://aur.archlinux.org/cgit/aur.git/snapshot/aurutils.tar.gz && \
    tar xf aurutils.tar.gz && \
    cd aurutils && \
    makepkg --syncdeps --noconfirm && \
    sudo pacman -U --noconfirm aurutils-*.pkg.tar.zst && \
    sudo mkdir /workspace && \
    sudo chown -R builder:builder /workspace && \
    cp /tmp/aurutils/aurutils-*.pkg.tar.zst /workspace/ && \
    repo-add /workspace/aurci2.db.tar.gz /workspace/aurutils-*.pkg.tar.zst && \
    echo "# local repository (required by aur tools to be set up)" | sudo tee -a /etc/pacman.conf && \
    echo "[aurci2]" | sudo tee -a /etc/pacman.conf && \
    echo "SigLevel = Optional TrustAll" | sudo tee -a /etc/pacman.conf && \
    echo "Server = file:///workspace" | sudo tee -a  /etc/pacman.conf

COPY update_repository.sh /usr/local/bin

CMD ["/usr/local/bin/update_repository.sh"]
