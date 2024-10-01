#ifndef VC_EXAMPLE_H  
#define VC_EXAMPLE_H  

void ListDevices(void); 
void ConnectToDevice(int num);
void DisconnectFromDevice(void);
void GetMessagesFromDevice(BOOL bQuiet = FALSE);
void SendMessageFromDevice(BOOL bQuiet = FALSE, BOOL bFd = TRUE);
void GetErrorsFromDevice(void);
void SetHSCANBaudRatetoDevice(int iRateToUse);
void SetAllCANFDBaudRates(int iBitRateToUse);
bool LoopbacktestProduction(uint64_t MaxTimeInSecs);
bool ConnectBySerialNumber(const char *SerialNumber);
bool Loopbacktest(BOOL bUseFd, uint64_t MaxTimeInSecs = 999999999);

#endif 
