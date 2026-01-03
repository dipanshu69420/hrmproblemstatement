from HCNetSDK import *

sdk = NetClient()
sdk.Init()
sdk.SetConnectTime(2000, 3)
sdk.SetReconnect(10000, True)
sdk.SetLogToFile(3)
ip='192.168.92.183'
port=8000
username='admin'
password='abcd@1234'
lUserId, device_info = sdk.Login_V40(ip, port, username, password)
print("Connected")