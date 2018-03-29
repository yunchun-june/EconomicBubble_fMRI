
classdef connector
    properties
        rule
        myID
        oppID
        ownIP
        ownPort
        destIP
        destPort
        serverSocket
        clientSocket
    end
    
    methods
        
        %contructor
        function obj = connector(rule,myID, oppID,ownIP, ownPort, destIP,destPort)
            import java.net.ServerSocket
            import java.io.*
            obj.rule = rule;
            obj.myID = myID;
            obj.oppID = oppID;
            obj.ownIP = ownIP;
            obj.ownPort = ownPort;
            obj.destIP = destIP;
            obj.destPort = destPort; 
        end
        
        %send and fetch
        
        function send(obj,message,timeout)
            server(message,obj.ownPort,timeout);
        end
        
        function data = fetch(obj,timeout)
            data = client(obj.destIP,obj.destPort,timeout);
        end
        
        % methods
        
        function establish(obj,myID,oppID)
            fprintf('-----------------------------\n');
            fprintf('Establishing Connection ....\n');
            
            if(strcmp(obj.rule,'player1'))
                sentMessage = strcat(myID,',',oppID);
                reveivedMessage = strcat(myID,',',oppID);
                obj.send(sentMessage,-1);
                fprintf('Mesage sent to player2.\n');
                syncResult = obj.fetch(-1);
                assert(strcmp(syncResult,reveivedMessage));
                fprintf('Recieved meeesge from player2.\n');
            end
            
            if(strcmp(obj.rule , 'player2'))
                sentMessage = strcat(oppID,',',myID);
                reveivedMessage = strcat(oppID,',',myID);
                syncResult = obj.fetch(-1);
                assert(strcmp(syncResult,reveivedMessage));
                fprintf('Recieved message from player1.\n');
                obj.send(sentMessage,-1);
                fprintf('Message sent to player1.\n');
            end
            
            fprintf('Connection Established\n');
            fprintf('-----------------------------\n');
        end

        function syncTrial(obj,trial)
            if strcmp(obj.rule , 'player1')
                obj.send(num2str(trial),-1);
                oppRes = obj.fetch(-1);
                assert(strcmp(num2str(trial), oppRes));
            end
            
            if strcmp(obj.rule ,'player2')
                oppRes = obj.fetch(-1);
                assert(strcmp(num2str(trial), oppRes));
                obj.send(num2str(trial),-1);
            end
        end

        function oppRes = sendOwnResAndgetOppRes(obj,myResStr)
            fprintf('Sending data...\n');
            if strcmp(obj.rule , 'player1')
                obj.send(myResStr,-1);
                oppRes = obj.fetch(-1);
                status = 1;
            end
            if strcmp(obj.rule , 'player2')
                oppRes = obj.fetch(-1);
                obj.send(myResStr,-1);
                status = 1;
            end
            fprintf('Data sent and received.\n');
        end

    end
end
    
