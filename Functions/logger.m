classdef logger
   properties
   end
   
   methods
       function obj = logger()
       end
       function log(obj,output)
           fprintf(output);
       end
   end
    
end