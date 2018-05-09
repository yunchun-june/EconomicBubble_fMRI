classdef dataHandler <handle

%    %column                 index
%    trials                 =1
%    marketCondition        =2
%    marketDramatic         =3
%    stockPrice             =4
%    player1Cash            =5
%    player1Stock           =6
%    player1TotalAsset      =7
%    player2Cash            =8
%    player2Stock           =9
%    player2TotalAsset      =10
%    player1Decision        =11
%    player1event           =12
%    player2Decision        =13
%    player2event           =14
%    p1startofTrial         =15
%    p2startofTrial         =16

    properties
        player1ID
        player2ID
        rule
        totalTrial
        result
    end
    
    methods
        
        %-----Constructor-----%
        function obj = dataHandler(ID1,ID2,rule,trials)
            obj.player1ID = ID1;
            obj.player2ID = ID2;
            obj.rule = rule;
            obj.totalTrial = trials+1;
            obj.result = cell(trials,16);
        end
        
        %----- Updating Data -----%
        function updateCondition(obj,mrk,me,opp,trial)
            
            obj.result{trial,1} = trial;
            obj.result{trial,2} = mrk.marketCondition;
            obj.result{trial,3} = mrk.dramatic;
            obj.result{trial,4} = mrk.stockPrice;
            
            if strcmp(obj.rule, 'player1')
                p1 = me;
                p2 = opp;
            end
            
            if strcmp(obj.rule , 'player2')
                p1 = opp;
                p2 = me;
            end

            obj.result{trial,5} = p1.cash;
            obj.result{trial,6} = p1.stock;
            obj.result{trial,7} = p1.getTotalAsset(mrk.stockPrice);
            obj.result{trial,8} = p2.cash;
            obj.result{trial,9} = p2.stock;
            obj.result{trial,10} = p2.getTotalAsset(mrk.stockPrice);
        end
        
        function saveResponse(obj,myRes,oppRes,trial)
            
            if strcmp(obj.rule, 'player1')
                p1Res = myRes;
                p2Res = oppRes;
            end
            
            if strcmp(obj.rule , 'player2')
                p1Res = oppRes;
                p2Res = myRes;
            end
            
            obj.result{trial,11} = p1Res.decision;
            obj.result{trial,12} = p1Res.events;
            obj.result{trial,13} = p2Res.decision;
            obj.result{trial,14} = p2Res.events;
            
            obj.result{trial,15} = p1Res.startOfTrial;
            obj.result{trial,16} = p2Res.startOfTrial;
            
        end
        
        function logStatus(obj,trial)
            fprintf('=================================================\n');
            fprintf('Trial          %d\n',trial);
            fprintf('Stock Price    %d\n',obj.result{trial,4});
            
            if strcmp(obj.rule , 'player1')
                fprintf('Cash    Stock   Asset\n');
                fprintf('%d      %d      %d\n',obj.result{trial,5},obj.result{trial,6},obj.result{trial,7});
                fprintf('Opponent asset: %d\n', obj.result{trial,10});
            end
            
            if strcmp(obj.rule , 'player2')
                fprintf('Cash    Stock   Asset\n');
                fprintf('%d      %d      %d\n',obj.result{trial,8},obj.result{trial,9},obj.result{trial,10});
                fprintf('Opponent asset: %d\n', obj.result{trial,7});
            end
            
        end
        
        function data = getStatusData(obj,i)
            data.stockPrice = obj.result{i,4};
            
            if strcmp(obj.rule, 'player1')
                data.cash = obj.result{i,5};
                data.stock = obj.result{i,6};
                data.stockValue = obj.result{i,6}* obj.result{i,4};
                data.totalAsset= obj.result{i,7};
                data.rivalTotal = obj.result{i,10};
                oppDecision= cell(1,5);
                
                for back= 5:-1:1  
                    if i-back <=0 
                        oppDecision{1,back} = '.';  
                    else  
                        oppDecision{1,back} = obj.result{i-back,13};
                    end  
                end 
                data.oppDecision = oppDecision; 
            end
            
            if strcmp(obj.rule, 'player2')
                data.cash = obj.result{i,8};
                data.stock = obj.result{i,9};
                data.stockValue = obj.result{i,9}*obj.result{i,4};
                data.totalAsset= obj.result{i,10};
                data.rivalTotal = obj.result{i,7};
                oppDecision= cell(1,5);  
                
                for back= 5:-1:1  
                    if i-back <=0 
                        oppDecision{1,back} = '.';  
                    else
                        oppDecision{1,back} = obj.result{i-back,11}; 
                    end
                end 
                data.oppDecision = oppDecision;
            end
            
            if i ==1
                data.change = 0;
                data.d1 = 'no trade';
                data.d2 = 'no trade';
            else
                data.change = obj.result{i,4}-obj.result{i-1,4};
                if strcmp(obj.rule, 'player1')
                    data.d1 = obj.result{i-1,11};
                    data.d2 = obj.result{i-1,13};
                end
                if strcmp(obj.rule, 'player2')
                    data.d1 = obj.result{i-1,13};
                    data.d2 = obj.result{i-1,11};
                end
                
            end
        end
        
        function data = getResult(obj)
            if strcmp(obj.rule, 'player1')
                data.myCash = obj.result{obj.totalTrial,5};
                data.oppCash = obj.result{obj.totalTrial,8};
            end
            if strcmp(obj.rule, 'player2')
                data.myCash = obj.result{obj.totalTrial,8};
                data.oppCash = obj.result{obj.totalTrial,5};
            end
        end
        
        %----- Writing and Loading -----%
        function saveToFile(obj)
            result = obj;
            filename = strcat('./RawData/EBG',datestr(now,'YYmmDD'),'_',datestr(now,'HHMM'),'_',obj.player1ID,'.mat');
            save(filename,'result');
            fprintf('Data saved to file.\n');
        end
        
        function data = loadData(obj,filename)
            rawData = load(filename);
            data = rawData.result;
        end
        
    end
    
end

