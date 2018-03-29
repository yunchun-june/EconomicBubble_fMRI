classdef displayer < handle
    %UNTITLED2 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        wPtr
        width
        height
        xCen
        yCen
        screenID
        row
        col
        decideTime
        displayerOn
    end
    
    properties (Constant)
        WHITE = [255 255 255];
        YELLOW = [255 255 0];
        GREEN = [0 255 0];
        RED = [255 0 0];
        GREY = [100 100 100];
        DIMYELLOW = [100 100 0];
        yLine = [23 29 35 41 47 53 59 65 71 77];
    end
    
    methods
        
        %===== Constructor =====%
        function obj = displayer(screid,displayerOn,decideTime)
            obj.screenID = screid;
            obj.decideTime = decideTime;
            obj.displayerOn = displayerOn;
        end
        
        %===== Open Close Screen =====%
        function openScreen(obj)
            if ~obj.displayerOn return; end
            
            [obj.wPtr, screenRect]=Screen('OpenWindow',obj.screenID, 0,[],32,2);
            [obj.width, obj.height] = Screen('WindowSize', obj.wPtr);
            obj.xCen = obj.width/2;
            obj.yCen = obj.height/2;
            for i = 1:10
                obj.row(i) = -(i-6)*obj.height/10;
            end
            
            for i = 1:5
                obj.col(i) = (i-3)*obj.width/6;
            end
        end
        
        function closeScreen(obj)
            if ~obj.displayerOn return; end
            Screen('CloseAll');
        end
        
        %===== Display =====%
        
        function writeMessage(obj,line1,line2)
            if ~obj.displayerOn return; end
            obj.write(line1,40,3,'white',30);
            obj.write(line2,40,5,'white',30);
            Screen('Flip',obj.wPtr);
        end
                
        function blackScreen(obj)
            if ~obj.displayerOn return; end
            Screen('Flip',obj.wPtr);
        end
        
        function fixation(obj,fixationTime)
            if ~obj.displayerOn return; end
            l = 10;
            
            %delay
            Screen('Flip',obj.wPtr);
            WaitSecs(1);
            
            %fixation square
            Screen('FillRect', obj.wPtr, obj.WHITE, [obj.xCen-l,obj.yCen-l,obj.xCen+l,obj.yCen+l]);
            Screen('Flip',obj.wPtr);
            WaitSecs(fixationTime);
            
            %delay
            Screen('Flip',obj.wPtr);
            WaitSecs(1);
        end
        
        function delay(obj,time)
            if ~obj.displayerOn return; end
            Screen('Flip',obj.wPtr);
            WaitSecs(time);
        end

        function showDecision(obj,data,temp,see,timer,confirmed)
            divider = '-----------------------------------------------------------------------------------';
            if ~obj.displayerOn return; end
            
            %--------------------------------------
            %1 Stock Price:  112(+6)
            %2 Stock         10
            %3 Stock Value   1000          ******
            %4 Cash          10000
            %5
            %6 Total         11000      Rivals  11000
            %7
            %8   buy  no trade  sell       timer
            %--------------------------------------
            
            %1 Stock Price:  112(+6)
            obj.write('Stock Price:',20,1,'white',30);
            obj.write(num2str(data.stockPrice),40,1,'white',30);
            if data.change<0
                output = strcat('(',num2str(data.change),')');
                obj.write(output,45,1,'green',30);
            end
            
            if data.change ==0
                obj.write('(+0)',45,1,'white',30);
            end
            
            if data.change>0
                output = strcat('(+',num2str(data.change),')');
                obj.write(output,45,1,'red',30);
            end
            
            %2 Stock Hold  10
            %3 Stock Value 1000
            %4 Cash        10000
            %5
            %6 Total       11000
            
            obj.write('Stock Hold',20,2,'white',30);
            obj.write('Stock Value',20,3,'white',30);
            obj.write('Cash',20,4,'white',30);
            obj.write('Total',20,6,'white',30);
            
            obj.write(num2str(data.stock),40,2,'white',30);
            obj.write(num2str(data.stockValue),40,3,'white',30);
            obj.write(num2str(data.cash),40,4,'white',30);
            obj.write(num2str(data.totalAsset),40,6,'white',30);

            %3 ******
            %4 
            %5
            %6 Rivals  11000
             
            for i = 5:-1:1
                startpoint= 60;
                if see
                    if strcmp(data.oppDecision{1,i},'.') obj.write('.',startpoint+i,3,'white',30); end
                    if strcmp(data.oppDecision{1,i},'buy') obj.write('B',startpoint+i,3,'red',18); end
                    if strcmp(data.oppDecision{1,i},'no trade') obj.write('N',startpoint+i,3,'white',18); end
                    if strcmp(data.oppDecision{1,i},'sell') obj.write('S',startpoint+i,3,'green',18); end
                else
                    obj.write('*',startpoint+i,3,'white',30);
                end
            end
            
            obj.write('Rival Total:',55,6,'white',30);
            obj.write(num2str(data.rivalTotal),70,6,'white',30);
            
            obj.write(divider,20,7,'white',30);
            
            % buy     no trade    sell    [timer]
            
            if timer <= obj.decideTime
                obj.write('Buy'      ,27,8,'white',30);
                obj.write('No Trade' ,43,8,'white',30);
                obj.write('Sell'     ,59,8,'white',30);

                if confirmed == 0
                    if strcmp(temp ,'buy')      obj.write('Buy'     ,27,8,'yellow',30); end
                    if strcmp(temp ,'no trade') obj.write('No Trade',43,8,'yellow',30); end
                    if strcmp(temp ,'sell')     obj.write('Sell'    ,59,8,'yellow',30); end
                end

                if confirmed == 1
                    if strcmp(temp ,'buy')      obj.write('Buy'     ,27,8,'red',30); end
                    if strcmp(temp ,'no trade') obj.write('No Trade',43,8,'red',30); end
                    if strcmp(temp ,'sell')     obj.write('Sell'    ,59,8,'red',30); end
                end
            end
            
            obj.drawTimer(timer,45,10);
            Screen('Flip',obj.wPtr);
        end
        
        function write(obj,text,x,y,c,size)
            if strcmp(c,'white') color = obj.WHITE; end
            if strcmp(c,'red') color = obj.RED; end
            if strcmp(c,'green') color = obj.GREEN; end
            if strcmp(c,'yellow') color = obj.YELLOW; end

            Screen('TextSize', obj.wPtr,size);
            Screen('DrawText',obj.wPtr,char(text), ceil(x*obj.width/100), ceil(obj.yLine(y)*obj.height/100), color);
            
        end
        
        function drawTimer(obj,t,xPosi,yPosi)
            w = 3;
            h = 20;
            margin = 13;
            x = ceil(xPosi*obj.width/100);
            y = ceil(obj.yLine(yPosi)*obj.height/100);
            for i = 1:t
                if i <= obj.decideTime
                    Screen('FillRect', obj.wPtr, obj.DIMYELLOW, [x,y,x+w,y+h]);
                else
                    Screen('FillRect', obj.wPtr, obj.GREY, [x,y,x+w,y+h]);
                end
                x = x+margin;
            end

        end
        
        function showResult(obj,result)
            obj.write('[ Fianl Result ]',38,3,'white',30);
            
            obj.write('Your Cash',30,4,'white',30);
            obj.write(num2str(result.myCash),50,4,'white',30);
            obj.write('Opponent Cash',30,5,'white',30);
            obj.write(num2str(result.oppCash),50,5,'white',30);
            
            if (result.myCash > result.oppCash)
                obj.write('YOU WIN',40,6,'red',30);
                fprintf('[RESULT] you win\n');
            end
            if (result.myCash == result.oppCash)
                obj.write('DRAW ',40,6,'white',30);
                fprintf('[RESULT] draw\n');
            end
            if (result.myCash < result.oppCash)
                obj.write('YOU LOSE',40,6,'green',30);
                fprintf('[RESULT] you lose\n');
            end
            Screen('Flip',obj.wPtr);
        end
        
    end
    
end

