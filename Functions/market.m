classdef market < handle

    properties
        marketCondition
        stockPrice
        dramatic
    end
    
    properties (Constant)
        BASELINE = 1;
        BUBBLE = 2;
        BURST = 3;
        BUY = 1;
        NO_TRADE = 2;
        SELL = 3;
                          %buy  notrade sell
        baselineRate    = [1.05  1.03   1.00; %buy
                           1.03 1.00   0.97; %notrade
                           1.00 0.97   0.95]; %sell
        bubbleRate      = [1.10 1.06   1.00;
                           1.06 1.00   0.97;
                           1.00 0.97   0.95];
        burstRate       = [1.05 1.03   1.00;
                           1.03 1.00   0.94;
                           1.00 0.94   0.90];
    end
    
    %=======================%
    
    methods
        %constructor
        function obj = market(condition,stockPrice)
            obj.marketCondition = condition;
            obj.stockPrice = stockPrice;
            obj.dramatic = 0;
        end
        
        function trade(obj,p1,p2)
            switch p1
                case 'buy'
                    p1Act = 1;
                case 'no trade'
                    p1Act = 2;
                case 'sell'
                    p1Act = 3;
                otherwise
                    p1Act = 2;
            end
            
            switch p2
                case 'buy'
                    p2Act = 1;
                case 'no trade'
                    p2Act = 2;
                case 'sell'
                    p2Act = 3;
                otherwise
                    p2Act = 2;
            end
            
            if(obj.marketCondition == obj.BASELINE)
                rate = obj.baselineRate(p1Act,p2Act);
            end
            if(obj.marketCondition == obj.BUBBLE)
                rate = obj.bubbleRate(p1Act,p2Act);
            end
            if(obj.marketCondition == obj.BURST)
                rate = obj.burstRate(p1Act,p2Act);
            end
            
            if obj.dramatic == 1
                rate = rate + (rate-1)*2;
            end
            
            obj.stockPrice = ceil(obj.stockPrice * rate);
        end

        
        function setCondition(obj,condition)
            display = {'baseline';'bubble';'burst'};
            fprintf('Set market condition: %d\n',display{condition});
            obj.marketCondition = condition;
        end
        
        function setDramatic(obj,dramatic)
            obj.dramatic = dramatic;
        end
        
    end

end