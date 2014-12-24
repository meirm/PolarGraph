void findSerialPort() {

  serialString = Serial.list();  

  println(serialString);   

  for (int i = serialString.length - 1; i > 0; i--) {  

    serialCheck = serialString[i];  
    serialIndex = serialCheck.indexOf(portName);  

    if (serialIndex > -1) portNumber = i;
  }
  println("Connecting to ("+ portNumber + ") " + serialString[portNumber]);
}    
void makeConnection() {
  findSerialPort();
  myPort = new Serial(this, Serial.list()[portNumber], 57600); 
  myPort.bufferUntil('\n'); 
  connected=true;
}
