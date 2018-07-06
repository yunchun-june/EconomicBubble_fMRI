
#!/usr/bin/python3           # This is server.py file
import socket
import time
        
def fetch(s):
    time.sleep(1)
    msg = s.recv(1024)  
    msg = msg.decode('ascii')
    
    while '@' not in msg:
        time.sleep(0.5)
        new_msg = s.recv(1024)  
        msg = msg + new_msg.decode('ascii')
    
    print('Msg:' + msg)
    return msg

def send(s,msg):
    s.send(msg.encode('ascii'))
        
# create a socket object
serversocket = socket.socket(socket.AF_INET, socket.SOCK_STREAM) 

host = '140.112.62.11' #hpc
port = 7676
serversocket.bind((host, port))                                  
serversocket.listen(5)

NTU = []
NCCU = []
NTUconnected = False
NCCUconnected = False

# get the first connection

print('Waiting for connections...')
clientsocket1, addr = serversocket.accept()      
print("Got a connection from %s" % str(addr))
msg = fetch(clientsocket1)
if msg == 'NTU@':
    NTU = clientsocket1
    NTUaddr = addr
    NTUconnected = True
    print('NTU connected.')
elif msg == 'NCCU@':
    NCCU = clientsocket1
    NCCUaddr = addr
    NCCUconnected = True
    print('NCCU connected.')
else:
    print('Get a unrecognized connection.')

# get the second connection

print('Waiting for connections...')
clientsocket2, addr = serversocket.accept()      
print("Got a connection from %s" % str(addr))
msg = fetch(clientsocket2)
if msg == 'NTU@':
    NTU = clientsocket2
    NTUaddr = addr
    NTUconnected = True
    print('NTU connected.')
elif msg == 'NCCU@':
    NCCU = clientsocket2
    NCCUaddr = addr
    NCCUconnected = True
    print('NCCU connected.')
else:
    print('Get a unrecognized connection.')

assert NTUconnected and NCCUconnected
    
while True:
    try:
        
        print('Waiting for message from NTU...')
        msg = fetch(NTU)
        send(NCCU,msg)
        print(msg+' sent to NCCU')
        
        print('Waiting for message from NCCU...')
        msg = fetch(NCCU)
        send(NTU,msg)
        print(msg+' sent to NTU')
        
    except KeyboardInterrupt:
        print('Stopping program and closing sockets...')
        NTU.close()
        NCCU.close()
        serversocket.close()
        print('END')