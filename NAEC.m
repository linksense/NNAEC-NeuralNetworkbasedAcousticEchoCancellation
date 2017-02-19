%% AEC Using Neural Network 
close all; clear; clc;

%% -----------------------Prepare Signal--------------------------
% 1. Far-end Signal
speakerFarEnd = 'F1';
farEndIndex   = 1;
audioName = ['.\Signal\SignalFarEnd\farEndSignal_DE_' speakerFarEnd '_' num2str(farEndIndex) '.raw'];
farEndSignal = loadshort(audioName); % load the speech file
farEndSignal = farEndSignal.';

% 2. Echo Signal
audioName = ['.\Signal\SignalEcho\echoSignal_DE_' speakerFarEnd '_' num2str(farEndIndex) '.raw'];
echoSignal = loadshort(audioName); % load the speech file
echoSignal = echoSignal.';

% 3. Near-end Signal
speakerNearEnd = 'M1';
nearEndIndex   = 1;
audioName = ['.\Signal\SignalNearEnd\nearEndSignal_EN_' speakerNearEnd '_' num2str(nearEndIndex) '.raw'];
nearEndSignal = loadshort(audioName); % load the speech file
nearEndSignal = nearEndSignal.';

% 4. Mic Signal with Noise
audioName = ['.\Signal\SignalMicNoise\micSignal_EN_' speakerNearEnd '_' num2str(nearEndIndex) '.raw'];
micSignalNoise = loadshort(audioName); % load the speech file
micSignalNoise = micSignalNoise.';

% 5. Mic Signal without Noise
audioName = ['.\Signal\SignalMicNoiseless\micSignal_EN_Noiseless_' speakerNearEnd '_' num2str(nearEndIndex) '.raw'];
micSignalNoiseless = loadshort(audioName); % load the speech file
micSignalNoiseless = micSignalNoiseless.';

% 6. Noise Signal
noiseSignal = loadshort('.\Signal\CarNoise32Sec.raw'); % load the speech file
noiseSignal = noiseSignal.';

%% ----------------------Init Neural Network----------------------
% Fast Kalman Filter
% lamda = 0.9992;
% delta = 1e-3;
% Np = 300;
% tInit=clock;
% [output,~,erleFKF] = FastKalmanFilter(lamda,delta,Np,farEndSignal(1:20000),echoSignal(1:20000));
% durationFKF=etime(clock,tInit);
% fprintf('FKF duration    = %d seconds.\n',durationFKF);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Echo State Network
% Prepare Data
Np = 300;
[inputMatrix,targetMatrix] = CreateInputTargetMatrix(Np,farEndSignal(192001:320000).',micSignalNoiseless(192001:320000).');
inputSequence  = inputMatrix.';
targetSequence = targetMatrix.';

% Adapt NN
nInputUnits = Np; nInternalUnits = 10; nOutputUnits = 1; 
%%%% Generate ESN for online RLS learning
inputScaling = 3*ones(Np,1);
inputShift   = 0*ones(Np,1);
s = rng(1239);
esn = GenerateESN(s,nInputUnits, nInternalUnits, nOutputUnits, ...
      'spectralRadius',0.8,'inputScaling',inputScaling,'inputShift',inputShift, ...
      'teacherScaling',1,'teacherShift',0,'feedbackScaling',1, ...
      'learningMode', 'online' , 'RLS_lambda',0.9998, 'RLS_delta',0.00001, ...
      'noiseLevel' ,0e-5); 
% train the ESN
tInit=clock;
[preSpeech,GpESN,erleESN,trainedESN] = OnlineEKRLSTrainESN(inputSequence,targetSequence,esn);
GpESN
durationESN=etime(clock,tInit);
fprintf('ESN duration    = %d seconds.\n',durationESN);
% preError = targetSequence-preSpeech;
% saveshort(preError,    'ESN_error.raw');
% % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Np = 200;
% [inputMatrix,targetMatrix] = CreateInputTargetMatrix(Np,farEndSignal(1:16000).',echoSignal(1:16000).');
% inputSequence  = inputMatrix.';
% targetSequence = targetMatrix.';
lamdaRLS = 0.9991;
deltaRLS = 0.1;
tInit=clock;
[preSignal,Gp,erleRLS] = OnlineEKRLS(inputSequence.',targetSequence,lamdaRLS,deltaRLS);
Gp
durationRLS=etime(clock,tInit);
fprintf('RLS duration    = %d seconds.\n',durationRLS);
% % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% mu = 1.2;
% deltaNLMS = 6;
% tInit=clock;
% [preSignalNLMS,predictError,GpNLMS,erleNLMS] = OnlineNLMS(inputSequence.',targetSequence,mu,deltaNLMS);
% durationNLMS=etime(clock,tInit);
% fprintf('NLMS duration    = %d seconds.\n',durationNLMS);

figure;
% plot(erleNLMS,'b-');hold on; grid on;
plot(erleRLS,'g-');hold on; grid on;
plot(erleESN,'r-');
% plot(erleFKF,'c-');
% pause;