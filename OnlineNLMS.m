function [preSignal,predictError,Gp,erle] = OnlineNLMS(trainInput,trainOutput,mu,delta)
[Np,L] = size(trainInput);
d_sum = 0;
deltad_sum = 0;

% Filter Parameters
% Filter Initialization
predictorPara = zeros(Np,1);        % Initial value of predictor parameter

%% Do Onling Learning 
fprintf('## Do online learning, Please wait... \n'); 
%>>>>>>>>>>>> Set the waitbar - Initialization <<<<<<<<<<<<<<<<<<
wb1 = waitbar(0, 'NLMS Online Training in Progress...');
for K = 1:L
     %>>>>>>>>>>>>>>>>> Display Waitbar <<<<<<<<<<<<<<<<<<<<<<
    waitbar(K/L,wb1)
    set(wb1,'name',['Progress = ' sprintf('%2.1f',K/L*100) '%']);
    %>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    
    % Acquire chunk of data
    currentPreSequence = trainInput(:,K);
    % Error signal equation
    currentPreSample = predictorPara(:,K)'*currentPreSequence;
    preSignal(K,1) = currentPreSample;
    
    predictError(K,1) = trainOutput(K,1)-currentPreSample;  
    
    energy = (currentPreSequence.'*currentPreSequence);
    normCurrSequenc = currentPreSequence./(delta+energy);
    predictorPara(:,K+1) = predictorPara(:,K) + (mu*predictError(K))*normCurrSequenc;
    
    d_sum       = d_sum + trainOutput(K,1)^2;
    deltad_sum  = deltad_sum + (trainOutput(K,1)- preSignal(K,1))^2;
    erle(K)     = 10*log10((d_sum+eps)/(deltad_sum+eps));

end
close(wb1);

plotEnable = 1;
if plotEnable == 1
    figure;
    plot(trainOutput,'b') ; hold on; grid on;
    plot(preSignal,'r');
    plot(predictError,'g');
    title('training: teacher sequence (blue) vs predicted sequence (red)') ; 
end
%% Prediction gain
Gp = 10*log10((sum(trainOutput.^2)/(sum(predictError.^2))+0.0000001));