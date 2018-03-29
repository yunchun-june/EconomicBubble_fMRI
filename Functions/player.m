classdef player < handle
    
    properties
        cash
        stock
    end
    
    %=======================%
    
    methods
        % constructor
        function obj = player(c,s)
            obj.cash = c;
            obj.stock = s;
        end
        
        function [] = showStatus(obj)
            disp(obj.cash)
            disp(obj.stock)
        end
        
        function totalAsset = getTotalAsset(obj,currentStockPrice)
            totalAsset = obj.cash + obj.stock*currentStockPrice;
        end
        
        function can = canBuy(obj,currentStockPrice)
            if(obj.cash > currentStockPrice)
                can = 1;
            else
                can = 0;
            end
        end
        
        function buyStock(obj,currentStockPrice)
            obj.cash = obj.cash - currentStockPrice;
            obj.stock = obj.stock+1;
        end
        
        function can = canSell(obj)
            if(obj.stock > 0)
                can = 1;
            else
                can = 0;
            end
        end
        
        function sellStock(obj,currentStockPrice)
            obj.cash = obj.cash + currentStockPrice;
            obj.stock = obj.stock-1;
        end
        
    end
end

