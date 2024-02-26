#ifndef ADD_H  
#define ADD_H  

bool Load_icsneo40DLL(void); 
void ListDevices(void); 
void ConnectToDevice(int num);
void DisconnectFromDevice(void);
void GetMessagesFromDevice(BOOL bQuiet = FALSE);
void SendMessageFromDevice(BOOL bQuiet = FALSE, BOOL bFd = TRUE);
void GetErrorsFromDevice(void);
void SetHSCANBaudRatetoDevice(int iRateToUse);


#endif 
