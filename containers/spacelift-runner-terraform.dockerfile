# This runner image installs the 1Password CLI `op` because it was required for the 1Password OpenTofu provider v2.
# In v3, 1Password migrated the provider to the 1Password SDK and it no longer requires the 1Password CLI.
# Although it is no longer required, The 1Password CLI has been retained here for backwards compatibility with v2.
# https://github.com/1Password/terraform-provider-onepassword/issues/228
# https://github.com/1Password/terraform-provider-onepassword/releases/tag/v3.0.0
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
