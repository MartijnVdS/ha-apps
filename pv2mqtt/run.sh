#!/usr/bin/with-contenv bashio

# Generate pv2mqtt.toml from HA options
CONFIG_PATH="/data/pv2mqtt.toml"

bashio::log.info "Generating pv2mqtt configuration..."

# Safely get MQTT URL
MQTT_URL=$(bashio::config 'mqtt_url' | jq -r 'if type == "string" then . else empty end')
if [ -z "$MQTT_URL" ] || [ "$MQTT_URL" == "null" ]; then
    bashio::log.info "No MQTT URL specified, using 'mqtt' service."
    MQTT_HOST=$(bashio::services "mqtt" "host")
    MQTT_PORT=$(bashio::services "mqtt" "port")
    MQTT_USER=$(bashio::services "mqtt" "username")
    MQTT_PASS=$(bashio::services "mqtt" "password")

    MQTT_PROTO="mqtt"
    if [ "$(bashio::services "mqtt" "ssl")" == "true" ]; then
        MQTT_PROTO="mqtts"
    fi
    MQTT_URL="${MQTT_PROTO}://${MQTT_USER}:${MQTT_PASS}@${MQTT_HOST}:${MQTT_PORT}"
fi

set -x

# Generate the final TOML configuration
# The application (pv2mqtt) performs its own validation of the configuration file.
jq -n \
  --arg url "$MQTT_URL" \
  --arg prefix "$(bashio::config 'topic_prefix' | jq -r 'if type == "string" then . else empty end')" \
  --argjson connections "$(bashio::config 'connections')" \
  --argjson devices "$(bashio::config 'devices')" \
  '
  {
    mqtt: {
      url: $url,
      client_id: "pv2mqtt",
      topic_prefix: $prefix,
      ha_prefix: "homeassistant"
    },
    connections: ($connections | map(
      .name as $conn_name |
      {
        name: .name,
        keep_alive_interval: .keep_alive_interval,
        modbus: ({
          type: (if .type | type == "array" then .type[0] else .type end),
          address: .address,
          device: .device,
          baud_rate: .baud_rate,
          parity: .parity,
          tls: .tls
        } | with_entries(select(.value != null))),
        devices: ($devices | map(select(.connection == $conn_name) | del(.connection)))
      } | with_entries(select(.value != null))
    ))
  }
  ' | yq -t . > "$CONFIG_PATH"

bashio::log.info "Starting pv2mqtt..."

# pv2mqtt reads the config file from the current working directory
cd /data
/usr/local/bin/pv2mqtt
