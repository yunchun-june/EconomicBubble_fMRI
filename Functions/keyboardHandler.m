classdef keyboardHandler < handle
    
    properties
       dev
       devInd
    end
    
    properties
        quitkey     = 'ESCAPE';
        confirm     = '6^';
        instructorConfirm = 'Return';
        buy         = '1!';  %'LeftArrow';
        noTrade     = '2@';  %'DownArrow';
        sell        = '3#';  %'RightArrow';
        see         = '4$';    %'UpArrow';
        trigger     = '5%';
    end
    
    methods
        
        %---- Constructor -----%
        function obj = keyboardHandler(mode)
            
            if strcmp(mode,'behavioral')
                obj.confirm     = 'space';
                obj.buy         = 'LeftArrow';
                obj.noTrade     = 'DownArrow';
                obj.sell        = 'RightArrow'; 
                obj.see         = 'UpArrow';
            end
            
            if strcmp(mode,'fMRI')
                obj.confirm     = '6^';
                obj.buy         = '1!';
                obj.noTrade     = '2@'; 
                obj.sell        = '3#'; 
                obj.see         = '4$'; 
            end
            
            if strcmp(mode,'fMRI_prac')
                obj.confirm     = '4$';
                obj.buy         = '6^'; 
                obj.noTrade     = '7&';
                obj.sell        = '8*'; 
                obj.see         = '9('; 
            end
            
            if strcmp(mode,'NTU')
                obj.confirm     = '6^';
                obj.buy         = '1!'; 
                obj.noTrade     = '2@'; 
                obj.sell        = '3#'; 
                obj.see         = '4$'; 
            end
            
            if strcmp(mode,'NCCU')
                obj.confirm     = '6^';
                obj.buy         = '1!';
                obj.noTrade     = '2@';
                obj.sell        = '3#';
                obj.see         = '4$';
            end
            
            obj.dev=PsychHID('Devices');
            
            if strcmp(mode,'NCCU')
                isKb = strcmpi('Keyboard', {obj.dev.usageName});
                isCurrent = strcmpi('Current Designs, Inc.', {obj.dev.manufacturer});
                obj.devInd = find(isKb & isCurrent);
                KbQueueCreate(obj.devInd);  
                KbQueueStart(obj.devInd);
            else
                obj.devInd = find(strcmpi('Keyboard', {obj.dev.usageName}) );
                KbQueueCreate();  
                KbQueueStart();
            end
            
            
            KbName('UnifyKeyNames');
        end
       
        %----- Functions -----%
        
        function [keyName, timing] = getResponse(obj,timesUp)
            
            keyName = 'na';
            timing = -1;
            
            KbEventFlush(obj.devInd);
            while GetSecs()<timesUp && strcmp(keyName,'na')
               [isDown, press, release] = KbQueueCheck(obj.devInd);
                
                if press(KbName(obj.quitkey))
                    keyName = 'quitkey';
                    timing = GetSecs();
                    return;
                end
               
                if press(KbName(obj.buy))
                    keyName = 'buy';
                    timing = GetSecs();
                end

                if press(KbName(obj.noTrade))
                    keyName = 'no trade';
                    timing = GetSecs();
                end

                if press(KbName(obj.sell))
                    keyName = 'sell';
                    timing = GetSecs();
                end

                if press(KbName(obj.confirm))
                    keyName = 'confirm';
                    timing = GetSecs();
                end
                
                if press(KbName(obj.see))
                    keyName = 'see';
                    timing = GetSecs();
                end
                
                if release(KbName(obj.see))
                    keyName = 'unsee';
                    timing = GetSecs();
                end
            end

        end
        
        function waitConfirmPress(obj)
            fprintf('[kbhandler]Waiting for confirm...\n');
            KbEventFlush();
            [keyIsDown, firstKeyPressTimes, firstKeyReleaseTimes] = KbQueueCheck(obj.devInd);
            while 1
                [keyIsDown, firstKeyPressTimes, firstKeyReleaseTimes] = KbQueueCheck(obj.devInd); 
                if firstKeyPressTimes(KbName(obj.confirm))
                    fprintf('[kbhandler]Confirm is pressed.\n');
                    break;
                end
            end
        end
        
        function waitESCPress(obj)
            fprintf('[kbhandler]Waiting for ESC...\n');
            KbEventFlush();
            [keyIsDown, firstKeyPressTimes, firstKeyReleaseTimes] = KbQueueCheck(obj.devInd);
            while 1
                [keyIsDown, firstKeyPressTimes, firstKeyReleaseTimes] = KbQueueCheck(obj.devInd); 
                if firstKeyPressTimes(KbName(obj.quitkey))
                    fprintf('[kbhandler]ESC is pressed.\n');
                    break;
                end
            end
        end
        
        function waitInstructorConfirm(obj)
            fprintf('[kbhandler]Waiting for Enter...\n');
            KbEventFlush();
            [keyIsDown, firstKeyPressTimes, firstKeyReleaseTimes] = KbQueueCheck(obj.devInd);
            while 1
                [keyIsDown, firstKeyPressTimes, firstKeyReleaseTimes] = KbQueueCheck(obj.devInd); 
                if firstKeyPressTimes(KbName(obj.instructorConfirm))
                    fprintf('[kbhandler]Enter is pressed.\n');
                    break;
                end
            end
        end
        
        function startTime = waitTrigger(obj)
            fprintf('[kbhandler]Waiting for trigger...\n');
            KbEventFlush();
            [keyIsDown, firstKeyPressTimes, firstKeyReleaseTimes] = KbQueueCheck(obj.devInd);
            while 1
                [keyIsDown, firstKeyPressTimes, firstKeyReleaseTimes] = KbQueueCheck(obj.devInd); 
                if firstKeyPressTimes(KbName(obj.trigger))
                    startTime = GetSecs();
                    break;
                end
            end
        end
        
        function waitTriggerStop(obj)
            fprintf('[kbhandler]Waiting for trigger to stop...\n');
            KbEventFlush();
            [keyIsDown, firstKeyPressTimes, firstKeyReleaseTimes] = KbQueueCheck(obj.devInd); 
            
            lastTrigger = GetSecs();
            while 1
                WaitSecs(0.5);
                [keyIsDown, firstKeyPressTimes, firstKeyReleaseTimes] = KbQueueCheck(obj.devInd); 
                
                if firstKeyPressTimes(KbName(obj.trigger))
                    lastTrigger = GetSecs();
                end
                                
                %fprintf('last trigger '+ num2str(lastTrigger) + ' secs ago.\n')
                if GetSecs() - lastTrigger > 5
                    fprintf('[kbhandler] Trigger stopped.\n')
                    break;
                end 
            end
            
        end
        
    end
    
end

