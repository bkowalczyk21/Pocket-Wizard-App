# NR1-App

## Bluetooth Services and Characteristics 

### Device Information Service
UUID: 180A

* Manufacturer Name String
    * UUID: 2A29
    * Read
    * 12 Bytes
* Model Number String
    * UUID: 2A24
    * Read
    * 10 Bytes
* Firmware Revision String
    * UUID: 2A26
    * Read
    * 5 Bytes

### Silicon Labs OTA
UUID: 1D14D6EE-FD63-4FA1-BFA4-8F47B42119F0

* OTA Control
    * UUID: F7BF3564-FB6D-4E53-88A4-5E37E0326063
    * Write
    * 1 Byte
* OTA Data
    * UUID: 984227F3-34FC-4045-A5D0-2C581F81A153
    * Write without response
    * 20 Bytes - OTA data

### NR1 Control
UUID: 91ea7e41-a26f-44d4-b4cc-a00422d870ac

* Channel Setting
    * UUID: ac606cb7-b8e7-4108-a962-b96736eb01d1
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
    * UUID: 86b764be-e328-4eff-9bcc-063878b32a35
    * Read
    * 3 Bytes
        * Byte 1 - X
        * Byte 2 - Y
        * Byte 3 - Z
* Contact Time
    * UUID: cc82ce42-adef-4f5e-bf73-97946297c002
    * Write and Read
    * 1 Byte 
        * TBD
* Trigger - trigger camera
    * UUID: 291dd0c8-9f69-4caa-82d1-90ad0c658118
    * Write
    * 1 Byte - default to 0 for now        
* Tamper Setting
    * UUID: d0512a4c-9329-11ea-bb37-0242ac130002 
    * Write and Read
    * 2 Bytes
        * Byte 1 - 0 = off, 1 = on
        * Byte 2 - 0 = low, 1 = med, 2 = high

