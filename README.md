Sousvide with esp8266

1) Clone and build https://github.com/pfalcon/esp-open-sdk.git
2) Clone https://github.com/nodemcu/nodemcu-firmware.git
3) Disable LUA_USE_MODULES_PWM, LUA_USE_MODULES_I2C, LUA_USE_MODULES_SPI and LUA_USE_MODULES_MQTT 
   to get more free memory for the lua stuff.
4) Build and flash it with "make ; make flash"
5) Upload the lua scripts by typing "make" in this directory.
6) Connect your laptop/tablet/phone to Sous0001 and go to http://192.168.4.1/config.html
7) Enter your ssid and network password and tap the "Configure and Reboot" button.
8) Check you server (or console output) for the IP address
9) Connect your laptop/tablet/phone to your wireless network and go to http://<ip>/index.html
