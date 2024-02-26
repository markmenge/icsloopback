### Building and Running Instructions

1. Clone the repository:
   ```
   git clone https://github.com/markmenge/icsloopback
   ```

2. Open `VCExample.sln` with Visual Studio 2017 or a newer version.

3. Ensure the Solution Platform is set to "Win32" and the build configuration is set to "Debug" (this should be the default setting).

4. Press `F5` to build and run the application.

### Production Test Guidelines

1. Install the loopback adapter ensuring the following connections:
   - CAN1 connected to CAN2
   - CAN3 connected to CAN4
   - Continue as needed for additional CAN interfaces.

2. Press `P` to initiate the Production Test.

3. Allow the test to run for approximately 4 hours. After completion, observe the Pass/Fail indication to determine the outcome.
   
