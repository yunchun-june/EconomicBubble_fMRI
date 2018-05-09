classdef keyboardHandler_fMRI < handle
    
    properties
       dev
       devInd
    end
    
    properties (Constant)
        quitkey     = 'ESCAPE';
        confirm     = '6^';
        buy         = '1!';  %'LeftArrow';
        noTrade     = '2@';  %'DownArrow';
        sell        = '3#';  %'RightArrow';
        see         = '4$';    %'UpArrow';
        trigger     = '5%';
    end
    
    methods
        
        %---- Constructor -----%
        function obj = keyboardHandler_fMRI()
            obj.setupKeyboard();
        end
        
        function setupKeyboard(obj)
           
            obj.dev=PsychHID('Devices');
            obj.devInd = find(strcmpi('Keyboard', {obj.dev.usageName}) );
            KbQueueCreate(obj.devInd);  
            KbQueueStart(obj.devInd);
            KbName('UnifyKeyNames');
        end
       
        %----- Functions -----%
        function detected = detectEsc(obj)
            
        end
        
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
        
    end
    
end

