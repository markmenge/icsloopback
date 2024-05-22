### Building and Running Instructions

1. Clone the repository:
   ```
   git clone https://github.com/markmenge/icsloopback
   ```

2. Open `VCExample.sln` with Visual Studio 2017 or a newer version.

3. Ensure the Solution Platform is set to "Win32" and the build configuration is set to "Debug" (this should be the default setting).

4. Press `F5` to build and run the application.

### Guide for installating a new version of VSpy3 or APIKit

Currently recommended firmware is 3.9.13.20. Note that settings are in a binary format, so they can be incorrect after a firmware update.

1. Run neoVI3GExplorer.exe

2. Connect and Manually Reflash if firmware is out-of-date.

3. Load Default Settings. 

4. Write Settings.

5. Disconnect

### Production Test Guidelines

1. Connect loopback adapter (see below)

2. Download and run loopback.exe (available here: https://github.com/markmenge/icsloopback/blob/main/Release/LoopbackTest.exe)

3. Press `P` to initiate the Production Test.

4. Allow the test to run for approximately 4 hours. After completion, observe the Pass/Fail indication to determine the outcome.

5. If successful: attach sticker: <Firmware Version> <Initials> PASS
   
Example:

3.9.13.20 MM Pass

### Loopback adapter
Build the loopback adapter to have buses connected to each other in pairs:

| Device       | Connections   |
|--------------|---------------|
| **RED2**     | CAN1 - CAN2   |
|              | CAN3 - CAN4   |
|              | CAN5 - CAN6   |
|              | CAN7 - CAN8   |
| **Fire2**    | CAN1 - MS     |
|              | CAN2 - CAN3   |
|              | CAN4 - CAN5   |
|              | CAN6 - CAN7   |
| **ValueCAN4**| CAN1 - CAN2   |

**Note:** A loopback plug has VERY short CAN bus lengths and breaks the normal rule of 2 120 Ohm terminators per bus.
I made my loopback adapter for a RED2/Fire2 by buying a DB26 Female Solderless Breakout Connector from Amazon.

