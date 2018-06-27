filename = "EBG180517_1636_test";

load(filename+".mat");

% block     1
% event(fix,think,nothing)
% timestamp
%

result = result.result;
r = cell(300,3);


for t = 1:100
    
    %block
    r{t*3-2,1} = ceil(t/20); 
    r{t*3-1,1} = ceil(t/20); 
    r{t*3,1} = ceil(t/20); 
    
    %event
    r{t*3-2,2} = "fixation"; 
    r{t*3-1,2} = "watch"; 
    r{t*3,2} = result{t,11}; 
    
    %event time
    res = result{t,12};
    pressNum = size(result{t,12});
    pressNum  = pressNum(1);
    
    if pressNum == 0
        r{t*3,2} = "not answered"; 
        r{t*3-2,3} = result{t,15};
        r{t*3-1,3} = result{t,15}+2;
        r{t*3,3} = "nan";
    else
        decidetime = str2double(res{pressNum,2});
        r{t*3-2,3} = result{t,15};
        r{t*3-1,3} = result{t,15}+2;
        r{t*3,3} = decidetime;
        
        if r{t*3,3}-r{t*3-1,3}<10
            r{t*3,2} = "not answered"; 
            r{t*3,3} = "nan";
        end
    end
    
end

cell2csv(filename+".csv",r);