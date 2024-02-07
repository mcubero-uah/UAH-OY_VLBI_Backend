clear 
SERVER_PORT = 1245;  % port of this server
u = udpport("datagram","IPV4","LocalPort", SERVER_PORT)
% Read reference epoch (Time server)
while true
    if (u.NumDatagramsAvailable > 0)  % if udp was received
        
        % read udp
        datagram = read(u, u.NumDatagramsAvailable, "uint8");
        
        % get datagram components
        ref_epoch = datagram.Data;
        
        senderAdress = datagram.SenderAddress;
        senderPort = datagram.SenderPort;
        
        sprintf('Received reference epoch: %d.', ref_epoch)
        seconds_from_epoch=VDIF_getsecondsfromepoch(ref_epoch)
        write(u, seconds_from_epoch, "uint32", senderAdress, senderPort);
        break
    end
end    

% Read VDIF Data (Recording server)
while true
    if (u.NumDatagramsAvailable > 0)  % if udp was received
        
        % read udp
        datagram = read(u, u.NumDatagramsAvailable, "uint32");
        
        % get datagram components
        data = datagram.Data;
%         break
    end
end 

clear u
senderAdress = datagram.SenderAddress;
senderPort = datagram.SenderPort; 

%Get values in hex 
hexData = cell(length(datagram), 1); % Inicializar una celda para almacenar los datos hexadecimales
for i=1:length(datagram)
hexData{i}=dec2hex(datagram(i).Data);
end