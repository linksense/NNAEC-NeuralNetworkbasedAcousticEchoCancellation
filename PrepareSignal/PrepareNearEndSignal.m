%% Directory of Database
[databaseDir,subdirs] = DatabaseDirectory;

speech = loadshort('en01f060.raw'); % load the speech file
speechTrans = speech(297:end).';
speech      = [speechTrans zeros(1,296)];
speechLength = length(speech);
quietPart = repmat(speech(120001:128000),1,8);

SLov = -26;   % signal level below the dynamic range
snr  = 15;    % 15 / 5 / 99
fs   = 16000;
% noise = loadshort('car-noise.raw'); % load the speech file
% noise = noise.';
% noise = repmat(noise,1,2);
noiseTemp = loadshort('noise_car_50sec_16000.raw'); % load the speech file
noiseTemp = noiseTemp(1:512000);
noise = sv56demo(noiseTemp, ['-qq -lev ' num2str(SLov-snr) ' -sf ' num2str(fs) ' -rms']);
noise = noise.';
saveshort(noise,'CarNoise32Sec.raw');

for subdirIndex = 5 %:size(subdirs,2)
    currentLanguage = [databaseDir subdirs{subdirIndex}];
    databaseFile = dir(currentLanguage);
    for speaker = 1:1:length(databaseFile)
        if (~strcmp(databaseFile(speaker).name(1), '.') && ~strcmp(databaseFile(speaker).name(1), '..'))
            
            disp([subdirs{subdirIndex} databaseFile(speaker).name]);
            fileIndex = 0;
            nearEndIndex = 0;
            nearEndSignal = [];
            if databaseFile(speaker).isdir
                databaseFileSub = dir([currentLanguage databaseFile(speaker).name '\*.raw']);        
                for speechFileIndex = 1:1:length(databaseFileSub)
                    currentSpeechFile = [currentLanguage databaseFile(speaker).name '\' databaseFileSub(speechFileIndex).name];
                    fprintf('## %s --> \n', currentSpeechFile); 
                    fileIndex = fileIndex+1;
                    
                    %% Step1. Load Speech File  *.raw
                    speech = loadshort(currentSpeechFile); % load the speech file
                    speechTrans = speech(297:end).';
                    speech      = [speechTrans zeros(1,296)];
                    % maxValue    = max(abs(speech));  
                    % speech      = speech./maxValue;
                    speechLength = length(speech);
                    if speechLength == 144000
                        speech = speech(8001:end-8000);
                    end
                    % quietPart = repmat(speech(63001:65000),1,32);
                    speech(1:64000) = quietPart;
                    nearEndSignal = [nearEndSignal speech];
                    
                    if mod(fileIndex,4) == 0
                        nearEndIndex = nearEndIndex+1;
                        
                        nearEndSignal = nearEndSignal - mean(nearEndSignal);
                        saveshort(nearEndSignal,'temp_in.raw');        
                        [~,result] = system('actlev.exe -q temp_in.raw');
                        idx = strfind(result,'ActLev[dB]: ');
                        actlevel = str2double(result(idx+12:idx+19));
                        factorNES = 10^((SLov - actlevel)/20);
                        delete temp_*.raw;
                        
                        nearEndSignal = factorNES*nearEndSignal;
                        
                        saveFileName = ['nearEndSignal_EN_' databaseFile(speaker).name '_' num2str(nearEndIndex) '.mat'];
                        saveAudioName = ['nearEndSignal_EN_' databaseFile(speaker).name '_' num2str(nearEndIndex) '.raw'];
                        save(saveFileName,'nearEndSignal');
                        saveshort(nearEndSignal,saveAudioName);
                        
                        fileEcho = ['echoSignal_DE_' databaseFile(speaker).name '_' num2str(nearEndIndex) '.raw'];
                        echoSignal = loadshort(fileEcho);
                        echoSignal = echoSignal.';

                        micSignal = nearEndSignal+echoSignal;
                        
                        saveFileName = ['micSignal_EN_Noiseless_' databaseFile(speaker).name '_' num2str(nearEndIndex) '.mat'];
                        saveAudioName = ['micSignal_EN_Noiseless_' databaseFile(speaker).name '_' num2str(nearEndIndex) '.raw'];
                        save(saveFileName,'micSignal');
                        saveshort(micSignal,saveAudioName);
                        
                        micSignal = nearEndSignal+echoSignal+noise;
                        
                        saveFileName = ['micSignal_EN_' databaseFile(speaker).name '_' num2str(nearEndIndex) '.mat'];
                        saveAudioName = ['micSignal_EN_' databaseFile(speaker).name '_' num2str(nearEndIndex) '.raw'];
                        save(saveFileName,'micSignal');
                        saveshort(micSignal,saveAudioName);
                        
                        nearEndSignal = [];
                    end
                end % end for "for speechFileIndex"
            end % end for "if databaseFile(j).isdir"
        end %end for "if ~strcmp"
    end % end for "for speaker"
end % end for "for subdirIndex"

pause;