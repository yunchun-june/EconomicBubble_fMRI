classdef parser
    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
    end
    
    methods
        function obj = parser()
        end
        
        function str = resToStr(obj, res)
            str = res.decision;
            
            %for i = 1:size(res.events)
            %    str = strcat(str,',',res.events{i,1},',',res.events{i,2});
            %end
        end
        
        function res = strToRes(obj,str)
            res.decision = str;
            res.startOfTrial = 0;
            res.events = cell(0,2);
            
            %sizec = size(c);
            %eventsNum = sizec(2)/2-1;
            
            %for i = 1:eventsNum
            %    res.events{end+1,1} = c{i*2+1};
            %    res.events{end,2} = str2double(c{i*2+2});
            %end
        end
    end
    
end

