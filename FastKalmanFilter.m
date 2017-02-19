function [output,Gp,erle] = FastKalmanFilter(lamda,delta,Np,input,target)
% Ensure row vectors ------------------------------------------------------
s=size(input);  if s(1)>s(2), input=input.';   end
s=size(target); if s(1)>s(2), target=target.'; end
% Initialization ----------------------------------------------------------
weight = zeros(Np,1);          % filter weight
inputLength = length(input);   % length of input signal
output = zeros(1,inputLength); % filter output

inputSequence = zeros(1,Np);   % 
gain = zeros(Np+1,1);          %
weightFor = zeros(Np,1);       %
weightBac = zeros(Np,1);       %

factor = delta*lamda^-2;
% Filtering ---------------------------------------------------------------
d_sum = 0;
deltad_sum = 0;
 %% Do Onling Learning 
fprintf('## Do online learning, Please wait... \n'); 
%>>>>>>>>>>>> Set the waitbar - Initialization <<<<<<<<<<<<<<<<<<
wb1 = waitbar(0, 'FKF Online Training in Progress...');

for i=1:inputLength
    %>>>>>>>>>>>>>>>>> Display Waitbar <<<<<<<<<<<<<<<<<<<<<<
    waitbar(i/inputLength,wb1)
    set(wb1,'name',['Progress = ' sprintf('%2.1f',i/inputLength*100) '%']);
    %>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
    
    % prior
    fpri = input(i)-inputSequence*weightFor;
    weightFor = weightFor+fpri*gain(1:Np);
    % post
    fpos = input(i)-inputSequence*weightFor;
    factor = lamda*factor+fpri'*fpos;
    gain = [0;gain(1:Np)]+(fpos'/factor)*[1;-weightFor];
    
    uiN = inputSequence(Np);
    inputSequence = [input(i),inputSequence(1:Np-1)];
    bpri = uiN-inputSequence*weightBac;
    
    gain(1:Np) = (gain(1:Np)+gain(Np+1)*weightBac)/(1-gain(Np+1)*bpri);
    weightBac = weightBac+bpri*gain(1:Np);
    
    % Compute error
    output(i) = inputSequence*weight;
    preError(i) = target(i)-output(i);
    
    % Update filter weight
    weight = weight + gain(1:Np)*preError(i);
    
     %--- Performance measurement 
    d_sum       = d_sum + target(i)^2;
    deltad_sum  = deltad_sum + preError(i)^2;
    erle(i)     = 10*log10((d_sum+eps)/(deltad_sum+eps));
end
close(wb1);% close waitbar.

plotEnable = 1;
if plotEnable == 1
    figure;
    plot(target,'b') ; hold on; grid on;
    plot(output,'r');
    plot(preError,'g');
    title('training: teacher sequence (blue) vs predicted sequence (red)') ; 
end

%% Gp
Gp  = 10*log10(sum(target.^2)/sum(preError.^2));