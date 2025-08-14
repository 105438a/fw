
Uart 接收過程
1. 偵測到起始位元 (Start Bit)
2. 硬體接收和組裝整個數據幀
3. 位元組進入接收緩衝區
4. Serial1.available() >= 1	
5. Serial1.read()

Serial1:
RX1 (接收): Pin 19
TX1 (發送): Pin 18

Serial2:
RX2 (接收): Pin 17
TX2 (發送): Pin 16

Serial3:
RX3 (接收): Pin 15
TX3 (發送): Pin 14
