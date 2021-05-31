# NR1-App
iOS application for delivering OTA firmware updates to and setting the channels, zones and modes on an inventory of remote camera triggers. AWS backend for firmware update storage. Also can visit the PcketWizard store.

## Bluetooth Services and Characteristics 

### Device Information Service

* Manufacturer Name String
    * Read
    * 12 Bytes
* Model Number String
    * Read
    * 10 Bytes
* Firmware Revision String
    * Read
    * 5 Bytes

### Silicon Labs OTA

* OTA Control
    * Write
    * 1 Byte
* OTA Data
    * Write without response
    * 20 Bytes - OTA data

### NR1 Control

* Channel Setting
    * Write and Read
    * 3 Bytes
        * Byte 1
            * 0 - Flash Channel
            * 1 - Camera Channel
        * Byte 2
            * Channel Number - 1 to 32 (flash) or 1 to 80 (camera) channel.
        * Byte 3
            * Zones (Bit Mask)
* Accelerometer Reading
    * Read
    * 3 Bytes
        * Byte 1 - X
        * Byte 2 - Y
        * Byte 3 - Z
* Contact Time
    * Write and Read
    * 1 Byte 
        * TBD
* Trigger - trigger camera
    * Write
    * 1 Byte - default to 0 for now        
* Tamper Setting
    * Write and Read
    * 2 Bytes
        * Byte 1 - 0 = off, 1 = on
        * Byte 2 - 0 = low, 1 = med, 2 = high

