# Use a minimal base image
FROM registry.access.redhat.com/ubi8/ubi-minimal:latest

USER root

# Update and install Podman in a single layer, then clean up
RUN microdnf update -y && \
    microdnf install -y podman && \
    microdnf clean all

# Copy and set the entrypoint script
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Set the entrypoint script as the entrypoint
ENTRYPOINT ["/entrypoint.sh"]
