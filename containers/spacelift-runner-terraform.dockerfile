# This runner image installs the 1Password CLI `op` because it was required for the 1Password OpenTofu provider v2.
# In v3, 1Password migrated the provider to the 1Password SDK and it no longer requires the 1Password CLI.
# Although it is no longer required, The 1Password CLI has been retained here for backwards compatibility with v2.
# https://github.com/1Password/terraform-provider-onepassword/issues/228
# https://github.com/1Password/terraform-provider-onepassword/releases/tag/v3.0.0
#
# Although the 1Password provider no longer requires the 1Password CLI, a custom runner image is still needed
# because the 1Password SDK requires additional dependencies on Alpine Linux.
# https://github.com/1Password/terraform-provider-onepassword/issues/340
FROM ghcr.io/spacelift-io/runner-terraform:latest

USER root

RUN <<INSTALL
set -e
echo https://downloads.1password.com/linux/alpinelinux/stable/ >>/etc/apk/repositories
wget https://downloads.1password.com/linux/keys/alpinelinux/support@1password.com-61ddfc31.rsa.pub -P /etc/apk/keys
apk update
apk add 1password-cli gcompat
apk cache clean
op --version
INSTALL

USER spacelift
