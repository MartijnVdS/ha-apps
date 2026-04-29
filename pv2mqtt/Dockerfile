FROM ghcr.io/home-assistant/base-debian:latest AS base

# Install requirements for the run script
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        jq \
        yq \
    && rm -rf /var/lib/apt/lists/*

# Copy the binary from from the official image
COPY --from=ghcr.io/martijnvds/pv2mqtt:v1.0.2 \
    /app/pv2mqtt \
    /usr/local/bin/pv2mqtt

# Copy the entrypoint script
COPY run.sh /
RUN chmod a+x /run.sh

CMD [ "/run.sh" ]
