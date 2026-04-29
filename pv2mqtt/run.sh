#!/usr/bin/with-contenv bashio

# Generate pv2mqtt.toml from HA options
CONFIG_PATH="/data/pv2mqtt.toml"

bashio::log.info "Generating pv2mqtt configuration..."

MQTT_URL=$(bashio::config 'mqtt_url')
if ! bashio::config.has_value 'mqtt_url'; then
    bashio::log.info "No MQTT URL specified, using 'mqtt' service."
    MQTT_HOST=$(bashio::service "mqtt" "host")
    MQTT_PORT=$(bashio::service "mqtt" "port")
    MQTT_USER=$(bashio::service "mqtt" "username")
    MQTT_PASS=$(bashio::service "mqtt" "password")

    MQTT_PROTO="mqtt"
    if [ "$(bashio::service "mqtt" "ssl")" == "true" ]; then
        MQTT_PROTO="mqtts"
    fi
    MQTT_URL="${MQTT_PROTO}://${MQTT_USER}:${MQTT_PASS}@${MQTT_HOST}:${MQTT_PORT}"
fi

# Validate connections
for connection in $(bashio::config 'connections | map(@json) | .[]'); do
    TYPE=$(echo "$connection" | jq -r '.type')
    NAME=$(echo "$connection" | jq -r '.name')

    if [ "$TYPE" == "tcp" ] && [ "$(echo "$connection" | jq -r '.address')" == "null" ]; then
        bashio::exit.nok "Connection '$NAME' is set to TCP but 'address' is missing!"
    fi

    if [ "$TYPE" == "rtu" ] && [ "$(echo "$connection" | jq -r '.device')" == "null" ]; then
        bashio::exit.nok "Connection '$NAME' is set to RTU but 'device' is missing!"
    fi
done

jq -n \
  --arg url "$MQTT_URL" \
  --arg prefix "$(bashio::config 'topic_prefix')" \
  --argjson connections "$(bashio::config 'connections')" \
  '
  {
    mqtt: {
      url: $url,
      client_id: "pv2mqtt-addon",
      topic_prefix: $prefix,
      ha_prefix: "homeassistant"
    },
    connections: ($connections | map({
      name: .name,
      keep_alive_interval: .keep_alive_interval,
      modbus: ({
        type: .type,
        address: .address,
        device: .device,
        baud_rate: .baud_rate,
        parity: .parity,
        tls: .tls
      } | with_entries(select(.value != null))),
      devices: .devices
    } | with_entries(select(.value != null))))
  }
  ' | yq -t . > "$CONFIG_PATH"

bashio::log.info "Starting pv2mqtt..."

# pv2mqtt reads the config file from the current working directory
cd /data
/usr/local/bin/pv2mqtt
