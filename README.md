# Martijn's Home Assistant Add-ons

This repository contains custom Home Assistant add-ons.

Apps documentation: <https://developers.home-assistant.io/docs/apps>

[![Open your Home Assistant instance and show the add app repository dialog with a specific repository URL pre-filled.](https://my.home-assistant.io/badges/supervisor_add_addon_repository.svg)](https://my.home-assistant.io/redirect/supervisor_add_addon_repository/?repository_url=https%3A%2F%2Fgithub.com%2FMartijnVdS%2Fha-apps)

## Available Add-ons

### [pv2mqtt](./pv2mqtt)

![Supports amd64 Architecture][amd64-shield]
![Supports aarch64 Architecture][aarch64-shield]

An MQTT Gateway for Solar Inverters, using SunSpec. It packages [pv2mqtt](https://github.com/MartijnVdS/pv2mqtt), which connects to your solar inverter via Modbus (TCP or RTU) and publishes its data to an MQTT broker.

After installation, go to the **Configuration** tab of the add-on to set up your inverter connection (IP address, Unit ID, etc.) and MQTT broker details.

[aarch64-shield]: https://img.shields.io/badge/aarch64-yes-green.svg
[amd64-shield]: https://img.shields.io/badge/amd64-yes-green.svg
