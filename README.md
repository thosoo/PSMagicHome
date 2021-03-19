# PSMagicHome
Controlling MagicHome LED Controller using PowerShell

## Description
There are many cheap smart LED Controllers of the Zengge manufacturer available on the market.
Some of them are based on the ESP8266, such they could be flashed with an alternative like [WLED](https://github.com/Aircoookie/WLED/).
Unfortunately, newer ones are based on a different, undocumented chinese chipset.
This made them very hard to be controlled from external applications.

Prior [reverse engineering](https://github.com/iUltimateLP/MagicHomeController/blob/master/REVERSE_ENGINEERING.md) efforts have already been made, which document the TCP- and
UDP-API of these devices. The discovery of these controllers is done via UDP broadcast, while
commands are issued via TCP. Each command has needs checksum, which needs to be calculated easily.

This projects ultimate goal is to create a tool that can bridge between the zengge LED controllers 
and [Hyperion.ng](https://github.com/hyperion-project/hyperion.ng). As only a single LED could be addressed,
this could be done by ready udpraw data, having a byte received for every color (in total 3 bytes) via UDP and
sent to the controller via TCP.

## Literature
- https://github.com/vikstrous/zengge-lightcontrol
- https://github.com/mjg59/python-zengge
- https://github.com/iUltimateLP/MagicHomeController
- https://github.com/sahilchaddha/homebridge-magichome-platform
- https://github.com/sidoh/ledenet_api
