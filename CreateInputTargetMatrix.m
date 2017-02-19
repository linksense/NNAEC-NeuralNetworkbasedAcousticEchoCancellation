function [inputMatrix,targetMatrix] = CreateInputTargetMatrix(Np,input,target)
targetDelay = Np;
input = input.';
input = input./2^15;

target = target.';
targetMatrix = target(:,targetDelay:end);

speechTrans  = input.';
lengthFile   = length(target);   

%% Form input data of NN (delay)        
slidWindowSize = targetDelay;
for endIndex=slidWindowSize:lengthFile    
    beginIndex = endIndex-(slidWindowSize-1);                  
    inputData(:,beginIndex) = speechTrans(endIndex:-1:beginIndex,:);
end

%% Input 
inputMatrix = inputData;

end