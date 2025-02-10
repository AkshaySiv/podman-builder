#!/bin/sh
set -eu

# Set container runtime to use Podman
export CONTAINER_RUNTIME=podman

# Default registry mirror URLs
DEFAULT_REGISTRY_MIRROR_1="https://shodan.svl.ibm.com:5000"
DEFAULT_REGISTRY_MIRROR_2="https://shodan.svl.ibm.com:5100"

# Create or update registries.conf file with the mirror URLs
cat <<EOF > /etc/containers/registries.conf
[registries.search]
registries = ['docker.io', 'quay.io', 'na-proxy-svl.artifactory.swg-devops.com', 'na-proxy-svl2.artifactory.swg-devops.com', 'us.icr.io']

[registries.insecure]
registries = []
[registries.block]
registries = []
[registries.forward]
registries = []
EOF

cat <<EOF > /etc/containers/containers.conf
[socket]
listen = "tcp://0.0.0.0:2375"

[containers]
netns="host"
EOF

cat <<EOF > /etc/containers/storage.conf
[storage]
# Default Storage Driver, Must be set for proper operation.
driver = "overlay"

# Runtime directory for temporary container storage.
runroot = "/run/containers/storage"

# Root directory where all container storage data resides.
graphroot = "/build/containers/storage"

[storage.options]
# List of additional image stores.
additionalimagestores = []

# Pull options for images (must be on a single line).
pull_options = { enable_partial_images = "false", use_hard_links = "false", ostree_repos = "" }

[storage.options.overlay]
# Mount options for overlay storage.
mountopt = "nodev"

[storage.options.thinpool]
# Storage options for thinpool.
# 'basesize' defines the default size for new container storage.
basesize = "50G"
EOF

# Parse the arguments and add registry mirror URLs to registries.conf
#while [ $# -gt 0 ]; do
#    if [ "$1" = "--registry-mirror" ]; then
#        # Append mirror URL to registries.conf
#        echo "${1} ${2}" >> /etc/containers/registries.conf
#        shift
#    fi
#    shift
#done

# Start Podman service in the background
podman system service --time=0 tcp://localhost:2375  &

# Tail a log file to keep the container running
tail -f /dev/null
