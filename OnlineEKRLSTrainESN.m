function [preSignal,onlineGp,erle,trainedESN] = OnlineEKRLSTrainESN(trainInput,trainOutput,esn)
% TRAIN_ESN Trains the output weights of an ESN 
% In the offline case, it computes the weights using the method
% esn.methodWeightCompute(for ex linear regression using pseudo-inverse)
% In In the online case, RLS is being used. 
%%%%%% inputs:
% trainInput = input vector of size nTrainingPoints x nInputDimension
% trainOutput = teacher vector of size nTrainingPoints x
% nOutputDimension
% esn = an ESN structure, through which we run our input sequence
% nForgetPoints - the first nForgetPoints will be disregarded
%%%%%% outputs: 
% trained_esn = an Esn structure with the option trained = 1 and 
% outputWeights set. 
% stateCollection = matrix of size (nTrainingPoints-nForgetPoints) x
% nInputUnits + nInternalUnits 
% stateCollectMat(i,j) = internal activation of unit j after the 
% (i + nForgetPoints)th training point has been presented to the network
% teacherCollection is a nSamplePoints * nOuputUnits matrix that keeps
% the expected output of the ESN
% teacherCollection is the transformed(scaled, shifted etc) output see
% compute_teacher for more documentation
%
% Created April 30, 2006, D. Popovici
% Copyright: Fraunhofer IAIS 2006 / Patent pending
% Revision 1, June 30, 2006, H. Jaeger
% Revision 2, Feb 23, 2007, H. Jaeger
d_sum = 0;
deltad_sum = 0;

trainedESN = esn;
if strcmp(trainedESN.learningMode, 'online')
    %% Init
    nSampleInput = length(trainInput);  
    netOut       = zeros(nSampleInput,1);
    Error     = zeros(nSampleInput,1); 
%     weights      = zeros(nSampleInput,1);
%     MSE          = zeros(nSampleInput,1);
    
    q = 3.8;
    beta = 2.20;
    alpha= 1;
    
    % trainWeight = trainedESN.nInternalUnits;
    % trainWeight = 2*(trainedESN.nInternalUnits);
    % trainWeight = 2*(trainedESN.nInternalUnits+trainedESN.nInputUnits);
    trainWeight = trainedESN.nInternalUnits+trainedESN.nInputUnits;
    P = (1/trainedESN.RLS_delta)*eye(trainWeight);% inverse correlation matrix
    A = alpha*eye(trainWeight);
    
    stateCollection = zeros(nSampleInput,trainWeight); 
    totalstate      = zeros(trainedESN.nTotalUnits,1);
    internalState   = zeros(trainedESN.nInternalUnits,1);  
    
    %% Do Onling Learning 
    fprintf('## Do online learning, Please wait... \n'); 
    %>>>>>>>>>>>> Set the waitbar - Initialization <<<<<<<<<<<<<<<<<<
    wb1 = waitbar(0, 'ESN Online Training in Progress...');
    
    for iInput = 1:nSampleInput
        %>>>>>>>>>>>>>>>>> Display Waitbar <<<<<<<<<<<<<<<<<<<<<<
        waitbar(iInput/nSampleInput,wb1)
        set(wb1,'name',['Progress = ' sprintf('%2.1f',iInput/nSampleInput*100) '%']);
        %>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
        
        if trainedESN.nInputUnits > 0
            in = [diag(trainedESN.inputScaling)*trainInput(iInput,:)'+trainedESN.inputShift];% in is column vector
        else
            in = [ ];
        end

        % write input into totalstate
        if trainedESN.nInputUnits > 0
            totalstate(trainedESN.nInternalUnits+1:trainedESN.nInternalUnits+trainedESN.nInputUnits) = in;
        end

        % update totalstate except at input positions
        % the internal state is computed based on the type of the network
        switch trainedESN.type
            case 'plain_esn'
                typeSpecificArg = [];
            case 'leaky_esn'
                typeSpecificArg = [];
            case 'twi_esn'
                if  trainedESN.nInputUnits == 0
                    error('twi_esn cannot be used without input to ESN');
                end

                if size(trainInput,2) > 1
                    trainedESN.avDist = mean(sqrt(sum(((trainInput(2:end,:)-trainInput(1:end-1,:))').^2)));
                else
                    trainedESN.avDist = mean(abs(trainInput(2:end,:)-trainInput(1:end-1,:)));
                end
                typeSpecificArg = trainedESN.avDist;                
        end
        
        internalState  = feval(trainedESN.type,totalstate,trainedESN,typeSpecificArg ); 
        % state = [internalState;internalState.^2]; 
        % state = [internalState;in;internalState.^2;in.^2];
        state = [internalState;in];
        % state = [internalState];
        netOut(iInput) = feval(trainedESN.outputActivationFunction,trainedESN.outputWeights*state);  
        %netOut(iInput) = feval(trainedESN.outputActivationFunction,trainedESN.outputWeights*[internalState]);  
        preSignal(iInput,1) = (netOut(iInput)-trainedESN.teacherShift)./trainedESN.teacherScaling;
        
        totalstate = [internalState;in;netOut(iInput,1)];
        stateCollection(iInput,:) = state';
        
       %% Update RLS parameters
        % Parameters for efficiency
        phi = state'*P;
        % Filter gain vector update
        gain = A*(phi'/(beta + trainedESN.RLS_lambda + phi*state));
        
        % Error signal equation
        Error(iInput,1) = trainOutput(iInput,1)-preSignal(iInput,1); 
        
        % network weights adaption
        trainedESN.outputWeights(1,:) = (A*trainedESN.outputWeights(1,:).'+gain*Error(iInput,1))';             
        % collect the weights for plotting 
        % weights(iInput,1) = sum(abs(trainedESN.outputWeights(1,:)));                        
        P = A*((P-gain*phi)/trainedESN.RLS_lambda)*A' + beta*q*eye(trainWeight);
        
        %--- Performance measurement 
        d_sum       = d_sum + trainOutput(iInput,1)^2;
        deltad_sum  = deltad_sum + (trainOutput(iInput,1)- preSignal(iInput,1))^2;
        erle(iInput)     = 10*log10((d_sum+eps)/(deltad_sum+eps));
        
    end
    close(wb1);% close waitbar.
    
    %% Prediction gain Global
    target    = trainOutput;
    Error  = target-preSignal;
    
    onlineGp  = 10*log10(sum(target.^2)/sum(Error.^2));
    
    plotEnable = 1;
    if plotEnable == 1
        figure;
        plot(target,'b') ; hold on; grid on;
        plot(preSignal,'r');
        plot(target-preSignal,'g');
        title('training: teacher sequence (blue) vs predicted sequence (red)') ; 
    end
        
else
    error('## If you want do online training, please set the learningMode be online!');

end
trainedESN.trained = 1;

%% frame based MSE and Gp
% speechFrame = reshape(speech,320,lengthFile/320);
% errorFrame = reshape(predictError,320,lengthFile/320);
% 
% frameBasedMSE = zeros(1,lengthFile/320);
% frameBasedGp = zeros(1,lengthFile/320);
% for frame = 1:1:(lengthFile/320)
%     frameBasedMSE(frame) = sum((errorFrame(:,frame).^2))/320;
%     
%     frameBasedEnergy     = (sum(speechFrame(:,frame).^2))/320;
%     frameBasedGp(frame)  = 10*log10((frameBasedEnergy/frameBasedMSE(frame))+0.0000001);
%     
% %     frameBasedMSE(frame) = 10*log10(frameBasedMSE(frame));
% end


end

