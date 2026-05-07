## v1.4.1-1

* Fix register offset for writing "model 704" power limit controls

## v1.4.0-1

* Update to upstream v1.4.0
* This adds all changes from upstream 1.2.0 - 1.4.0
  * Nameplate ratings (SunSpec models 120 or 702)
  * Support for "controls" (power limit and connect/disconnect)
    * Using SunSpec model 123 or 704
  * Support for SunSpec "Model 701" inverter data
  * Override for inverter model (in case the automatically picked one does not
    have all the information)

## v1.1.0-2

* Fix startup, by telling pv2mqtt where its config file is

## v1.1.0-1

* Add the ability to _set_ some inverter parameters:
  * Grid connection
  * Power limit (on/off and a percentage of max. power)
