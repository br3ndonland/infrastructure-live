FROM ghcr.io/spacelift-io/runner-terraform:latest

USER root

RUN <<INSTALL
set -e
echo https://downloads.1password.com/linux/alpinelinux/stable/ >>/etc/apk/repositories
wget https://downloads.1password.com/linux/keys/alpinelinux/support@1password.com-61ddfc31.rsa.pub -P /etc/apk/keys
apk update
apk add 1password-cli
apk cache clean
op --version
INSTALL

USER spacelift
