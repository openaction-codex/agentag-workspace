#!/usr/bin/env bash

set -Eeuo pipefail

readonly NVM_INSTALL_VERSION="v0.40.5"
readonly NODE_MAJOR_VERSION="24"
readonly PHP_VERSION="8.4"
readonly CODEX_MODEL="gpt-5.6-sol"
readonly CODEX_REASONING_EFFORT="xhigh"
readonly METAMCP_URL="https://mcp.openaction.eu/metamcp/oa-agent/mcp"
readonly METAMCP_TOKEN_VAR="OPENACTION_METAMCP_TOKEN"
readonly PROVISION_USER="$(id -un)"
readonly PLAYWRIGHT_CLI_CONFIG="${HOME}/.config/playwright-cli/cli.config.json"

log() {
    printf '\n\033[1;34m==> %s\033[0m\n' "$*"
}

die() {
    printf '\nError: %s\n' "$*" >&2
    exit 1
}

as_root() {
    if [[ "${EUID}" -eq 0 ]]; then
        "$@"
    else
        sudo "$@"
    fi
}

ensure_source_line() {
    local file="$1"
    local line="$2"

    touch "$file"
    grep -Fqx "$line" "$file" || printf '\n%s\n' "$line" >> "$file"
}

set_top_level_toml_value() {
    local file="$1"
    local key="$2"
    local value="$3"
    local temporary

    temporary="$(mktemp "${file}.tmp.XXXXXX")"
    awk -v key="$key" -v value="$value" '
        BEGIN { in_root = 1; written = 0 }
        in_root && /^[[:space:]]*\[/ {
            if (!written) {
                print key " = " value
                written = 1
            }
            in_root = 0
        }
        in_root && $0 ~ "^[[:space:]]*" key "[[:space:]]*=" {
            if (!written) {
                print key " = " value
                written = 1
            }
            next
        }
        { print }
        END {
            if (!written) {
                print key " = " value
            }
        }
    ' "$file" > "$temporary"
    chmod 600 "$temporary"
    mv "$temporary" "$file"
}

[[ -r /etc/os-release ]] || die "Cannot identify the operating system."
# shellcheck disable=SC1091
source /etc/os-release
[[ "${ID:-}" == "ubuntu" ]] || die "This provisioner supports Ubuntu only (found ${ID:-unknown})."

readonly UBUNTU_CODENAME="${UBUNTU_CODENAME:-${VERSION_CODENAME:-}}"
[[ -n "$UBUNTU_CODENAME" ]] || die "Ubuntu codename is missing from /etc/os-release."

log "Provisioning Ubuntu ${VERSION_ID:-unknown} (${UBUNTU_CODENAME}) for ${PROVISION_USER}"
as_root true

log "Upgrading system packages"
as_root env DEBIAN_FRONTEND=noninteractive apt-get update
as_root env DEBIAN_FRONTEND=noninteractive apt-get dist-upgrade -y
as_root env DEBIAN_FRONTEND=noninteractive apt-get install -y \
    apt-transport-https bubblewrap ca-certificates curl git gnupg lsb-release \
    software-properties-common sqlite3 unzip
as_root add-apt-repository -y universe
as_root apt-get update

log "Installing Docker Engine"
for conflicting_package in \
    docker.io docker-compose docker-compose-v2 docker-doc podman-docker containerd runc; do
    as_root apt-get remove -y "$conflicting_package" || true
done
as_root install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg \
    | as_root tee /etc/apt/keyrings/docker.asc >/dev/null
as_root chmod a+r /etc/apt/keyrings/docker.asc
printf 'Types: deb\nURIs: https://download.docker.com/linux/ubuntu\nSuites: %s\nComponents: stable\nArchitectures: %s\nSigned-By: /etc/apt/keyrings/docker.asc\n' \
    "$UBUNTU_CODENAME" "$(dpkg --print-architecture)" \
    | as_root tee /etc/apt/sources.list.d/docker.sources >/dev/null
as_root rm -f /etc/apt/sources.list.d/docker.list
as_root apt-get update
as_root env DEBIAN_FRONTEND=noninteractive apt-get install -y \
    containerd.io docker-buildx-plugin docker-ce docker-ce-cli docker-compose-plugin
as_root systemctl enable --now docker
if [[ "${EUID}" -ne 0 ]]; then
    as_root usermod -aG docker "$PROVISION_USER"
fi

log "Installing NVM ${NVM_INSTALL_VERSION} and Node.js ${NODE_MAJOR_VERSION}"
export NVM_DIR="${HOME}/.nvm"
curl -fsSL "https://raw.githubusercontent.com/nvm-sh/nvm/${NVM_INSTALL_VERSION}/install.sh" | bash
# shellcheck disable=SC1091
source "${NVM_DIR}/nvm.sh"
nvm install "$NODE_MAJOR_VERSION"
nvm alias default "$NODE_MAJOR_VERSION"
nvm use "$NODE_MAJOR_VERSION"

log "Installing PHP ${PHP_VERSION}"
sury_keyring_package="$(mktemp)"
trap 'rm -f "$sury_keyring_package"' EXIT
curl -fsSL https://packages.sury.org/debsuryorg-archive-keyring.deb \
    -o "$sury_keyring_package"
as_root dpkg -i "$sury_keyring_package"
rm -f "$sury_keyring_package"
trap - EXIT
printf 'deb [signed-by=/usr/share/keyrings/debsuryorg-archive-keyring.gpg] https://packages.sury.org/php/ %s main\n' \
    "$UBUNTU_CODENAME" \
    | as_root tee /etc/apt/sources.list.d/php.list >/dev/null
as_root apt-get update
as_root env DEBIAN_FRONTEND=noninteractive apt-get install -y \
    "php${PHP_VERSION}-apcu" \
    "php${PHP_VERSION}-amqp" \
    "php${PHP_VERSION}-bcmath" \
    "php${PHP_VERSION}-cli" \
    "php${PHP_VERSION}-common" \
    "php${PHP_VERSION}-curl" \
    "php${PHP_VERSION}-gd" \
    "php${PHP_VERSION}-gmp" \
    "php${PHP_VERSION}-intl" \
    "php${PHP_VERSION}-mbstring" \
    "php${PHP_VERSION}-opcache" \
    "php${PHP_VERSION}-pgsql" \
    "php${PHP_VERSION}-readline" \
    "php${PHP_VERSION}-redis" \
    "php${PHP_VERSION}-sqlite3" \
    "php${PHP_VERSION}-xml" \
    "php${PHP_VERSION}-zip"

# Remove links created by the previous source-build provisioner, if present.
for php_command in php php-config phpize; do
    php_link="/usr/local/bin/${php_command}"
    if [[ -L "$php_link" && "$(readlink "$php_link")" == "/opt/php/${PHP_VERSION}/bin/${php_command}" ]]; then
        as_root rm -f "$php_link"
    fi
done
as_root update-alternatives --set php "/usr/bin/php${PHP_VERSION}"

log "Installing Symfony CLI"
curl -fsSL https://get.symfony.com/cli/installer | bash
as_root install -m 0755 "${HOME}/.symfony5/bin/symfony" /usr/local/bin/symfony

log "Installing Composer"
composer_directory="$(mktemp -d)"
trap 'rm -rf "$composer_directory"' EXIT
curl -fsSL https://getcomposer.org/installer -o "${composer_directory}/composer-setup.php"
expected_checksum="$(curl -fsSL https://composer.github.io/installer.sig)"
actual_checksum="$(php -r "echo hash_file('sha384', '${composer_directory}/composer-setup.php');")"
[[ "$actual_checksum" == "$expected_checksum" ]] || die "Composer installer checksum verification failed."
php "${composer_directory}/composer-setup.php" \
    --install-dir="$composer_directory" --filename=composer --quiet
as_root install -m 0755 "${composer_directory}/composer" /usr/local/bin/composer
rm -rf "$composer_directory"
trap - EXIT

log "Installing Codex CLI"
npm install --global @openai/codex@latest

log "Installing Playwright CLI and headless Chromium"
npm install --global @playwright/cli@latest
playwright-cli install-browser chromium --with-deps --only-shell

log "Configuring Playwright CLI for the headless VPS"
install -m 0700 -d "$(dirname "$PLAYWRIGHT_CLI_CONFIG")"
printf '%s\n' \
    '{' \
    '  "browser": {' \
    '    "browserName": "chromium",' \
    '    "launchOptions": {' \
    '      "headless": true,' \
    '      "chromiumSandbox": false' \
    '    }' \
    '  }' \
    '}' > "$PLAYWRIGHT_CLI_CONFIG"
chmod 600 "$PLAYWRIGHT_CLI_CONFIG"
ensure_source_line "${HOME}/.bashrc" \
    "export PLAYWRIGHT_MCP_CONFIG=\"${PLAYWRIGHT_CLI_CONFIG}\""
export PLAYWRIGHT_MCP_CONFIG="$PLAYWRIGHT_CLI_CONFIG"

log "Configuring Codex"
install -m 0700 -d "${HOME}/.codex"
touch "${HOME}/.codex/config.toml"
chmod 600 "${HOME}/.codex/config.toml"
set_top_level_toml_value "${HOME}/.codex/config.toml" model "\"${CODEX_MODEL}\""
set_top_level_toml_value "${HOME}/.codex/config.toml" model_reasoning_effort "\"${CODEX_REASONING_EFFORT}\""

if [[ -z "${OPENACTION_METAMCP_TOKEN:-}" ]]; then
    [[ -t 0 ]] || die "Set ${METAMCP_TOKEN_VAR} before running non-interactively."
    read -r -s -p "MetaMCP bearer token: " OPENACTION_METAMCP_TOKEN
    printf '\n'
fi
[[ -n "$OPENACTION_METAMCP_TOKEN" ]] || die "The MetaMCP bearer token cannot be empty."

printf 'export %s=%q\n' "$METAMCP_TOKEN_VAR" "$OPENACTION_METAMCP_TOKEN" >> "${HOME}/.bashrc"
export OPENACTION_METAMCP_TOKEN

codex mcp remove metamcp >/dev/null 2>&1 || true
codex mcp add metamcp \
    --url "$METAMCP_URL" \
    --bearer-token-env-var "$METAMCP_TOKEN_VAR"

log "Installing rtk"
curl -fsSL https://raw.githubusercontent.com/rtk-ai/rtk/refs/heads/master/install.sh | sh
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc

log "Configuring Git identity"
git config --global user.name "OpenAction Agent"
git config --global user.email "agent@openaction.eu"

printf '\nProvisioning complete.\n\n'
printf 'Then start a new login shell (or reconnect over SSH) so environment changes apply.\n'
printf 'Finally, authenticate Codex with: codex login --device-auth\n'
