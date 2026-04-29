FROM ghcr.io/home-assistant/base-debian:latest AS base

# Use existing container image to extract binary
FROM ghcr.io/MartijnVdS/pv2mqtt:v1.0.2 AS pv2mqtt-source

# Install requirements for the run script
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        jq \
        yq \
    && rm -rf /var/lib/apt/lists/*

# Copy the binary from from the official image
COPY --from=pv2mqtt-source /app/pv2mqtt /usr/local/bin/pv2mqtt

# Copy the entrypoint script
COPY run.sh /
RUN chmod a+x /run.sh

CMD [ "/run.sh" ]
