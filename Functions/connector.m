
classdef connector
    properties
        rule
        myID
        oppID
        destIP
        destPort
        socket
        input_stream
        d_input_stream
        output_stream
        d_output_stream
    end
    
    methods
        
        %contructor
        function obj = connector(rule,myID, oppID,destIP,destPort)
            import java.net.Socket
            import java.io.*
            obj.rule = rule;
            obj.myID = myID;
            obj.oppID = oppID;
            obj.destIP = destIP;
            obj.destPort = destPort;
            
            while 1
                try
                    obj.socket = Socket(obj.destIP, obj.destPort);
                    obj.input_stream   = obj.socket.getInputStream;
                    obj.d_input_stream = DataInputStream(obj.input_stream);
                    obj.output_stream  = obj.socket.getOutputStream;
                    obj.d_output_stream = DataOutputStream(obj.output_stream);
                    break;
                catch
                    WaitSecs(0.5);
                end
            end
            
        end
        
        function connectHPC(obj)
            while 1
                try
                    import java.net.Socket
                    import java.io.*
                    
                    if(strcmp(obj.rule,'player1'))
                        obj.send('NTU');
                    end

                    if(strcmp(obj.rule,'player2'))
                        obj.send('NCCU');
                    end
                    
                    break;
                catch exception
                    %fprintf(1,'Error: %s\n',getReport(exception));
                    WaitSecs(0.5);
                end
                
            end
            
            
            
            fprintf('Connected to HPC.\n')
        end
        
        function close(obj)
            obj.socket.close();
        end
        
        %send and fetch
        
        function send(obj,message)
            import java.net.Socket
            import java.io.*
            message = [message '@'];
            %server(message,obj.ownPort,timeout);
            obj.d_output_stream.writeBytes(char(message));
            obj.d_output_stream.flush;
            fprintf('Message sent.');
            WaitSecs(1);
        end
        
        function data = fetch(obj)
            
            import java.net.Socket
            import java.io.*
            
            %data = client(obj.destIP,obj.destPort,timeout);
            while 1
                try
                    bytes_available = obj.input_stream.available;
                    while bytes_available == 0
                        WaitSecs(1);
                        bytes_available = obj.input_stream.available;
                    end

                    message = zeros(1, bytes_available, 'uint8');
                    for i = 1:bytes_available
                        message(i) = obj.d_input_stream.readByte;
                    end
                    
                    break
                    
                catch exception
                    WaitSecs(0.5);
                end
            end
            
            message = char(message);
            data = message(1:end-1); %remove the @ at the end
        end
        
        % methods
        
        function establish(obj,myID,oppID)
            fprintf('-----------------------------\n');
            fprintf('Connecting to HPC ....\n');
            
            obj.connectHPC();
            
            fprintf('Verifying Opponent ....\n');
            
            if(strcmp(obj.rule,'player1'))
                sentMessage = strcat(myID,',',oppID);
                reveivedMessage = strcat(myID,',',oppID);
                
                obj.send(sentMessage);
                
                fprintf('Mesage sent to player2.\n');
                syncResult = obj.fetch();
                assert(strcmp(syncResult,reveivedMessage));
                fprintf('Recieved meeesge from player2.\n');
            end
            
            if(strcmp(obj.rule , 'player2'))
                sentMessage = strcat(oppID,',',myID);
                reveivedMessage = strcat(oppID,',',myID);
                syncResult = obj.fetch();
                assert(strcmp(syncResult,reveivedMessage));
                fprintf('Recieved message from player1.\n');
                
                obj.send(sentMessage);
                
                fprintf('Message sent to player1.\n');
            end
            
            fprintf('Connection Established\n');
            fprintf('-----------------------------\n');
        end

        function syncTrial(obj,trial)
            if strcmp(obj.rule , 'player1')
                obj.send(num2str(trial));
                oppRes = obj.fetch();
                assert(strcmp(num2str(trial), oppRes));
            end
            
            if strcmp(obj.rule ,'player2')
                oppRes = obj.fetch();
                assert(strcmp(num2str(trial), oppRes));
                obj.send(num2str(trial));
            end
        end

        function oppRes = sendOwnResAndgetOppRes(obj,myResStr)
            fprintf('Sending data...\n');
            if strcmp(obj.rule , 'player1')
                obj.send(myResStr);
                oppRes = obj.fetch();
            end
            if strcmp(obj.rule , 'player2')
                oppRes = obj.fetch();
                obj.send(myResStr);
            end
            fprintf('Data sent and received.\n');
        end

    end
end
    
