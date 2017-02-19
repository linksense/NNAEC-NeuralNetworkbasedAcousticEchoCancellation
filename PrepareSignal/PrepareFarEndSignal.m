%% H1
h_LEM_1 = loadshort('ir1_16kHz_1s_sweep20-8000_blick-nach-vorn.raw');    % Touran LEM IR
h_LEM_1 = h_LEM_1(1:min(end,8000))./2^15;    % 1:8000^=500ms RIA    
if max(h_LEM_1) > 1
    h_LEM_1 = h_LEM_1./max(abs(h_LEM_1));
end
h_LEM_1(end:8000) = 0;
h_LEM_1 = h_LEM_1 / norm(h_LEM_1);

%%H2
h_LEM_2 = loadshort('ir2_16kHz_1s_sweep20-8000_blick-nach-hinten.raw');    % Touran LEM IR
h_LEM_2 = [zeros(10,1);h_LEM_2(1:min(8000-10,end-10))]./2^15;
if max(h_LEM_2) > 1
    h_LEM_2 = h_LEM_2./max(abs(h_LEM_2));
end
h_LEM_2(end:8000) = 0;
h_LEM_2 = h_LEM_2 / norm(h_LEM_2);

%% Directory of Database
[databaseDir,subdirs] = DatabaseDirectory;

for subdirIndex = 8 %:size(subdirs,2)
    currentLanguage = [databaseDir subdirs{subdirIndex}];
    databaseFile = dir(currentLanguage);
    for speaker = 1:1:length(databaseFile)
        if (~strcmp(databaseFile(speaker).name(1), '.') && ~strcmp(databaseFile(speaker).name(1), '..'))
            
            disp([subdirs{subdirIndex} databaseFile(speaker).name]);
            fileIndex = 0;
            farEndIndex = 0;
            farEndSignal = [];
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
                    farEndSignal = [farEndSignal speech];
                    
                    if mod(fileIndex,4) == 0
                        farEndIndex = farEndIndex+1;
                        saveFileName = ['farEndSignal_DE_' databaseFile(speaker).name '_' num2str(farEndIndex) '.mat'];
                        saveAudioName = ['farEndSignal_DE_' databaseFile(speaker).name '_' num2str(farEndIndex) '.raw'];
                        save(saveFileName,'farEndSignal');
                        saveshort(farEndSignal,saveAudioName);
                        
                        SLov = -26;   % signal level below the dynamic range
                        ser  = 5;     % 0 / 6 / Inf
                        farEndSignal = farEndSignal - mean(farEndSignal);
                        saveshort(farEndSignal,'temp_in.raw');
                        [~,result] = system('actlev.exe -q temp_in.raw');
                        idx = strfind(result,'ActLev[dB]: ');
                        actlevel = str2double(result(idx+12:idx+19));
                        factorFES = 10^((SLov-ser - actlevel)/20);
                        delete temp_in.raw;
                        
                        fs = 16000;
                        echoSignal = zeros(128000*4,1);    
                        windowlen = 0.02*fs;
                        window = hann(windowlen,'periodic');
                        hSwitchAt = 256000;
                        farEndSignal = farEndSignal.';
                        
                        [echoSignal(1:hSwitchAt+windowlen/4),states] = filter(h_LEM_1', 1, farEndSignal(1:hSwitchAt+windowlen/4));    
                        echoSignal(hSwitchAt-windowlen/4+1:hSwitchAt+windowlen/4) = echoSignal(hSwitchAt-windowlen/4+1:hSwitchAt+windowlen/4).*window(end-windowlen/2+1:end);

                        [temp, states] = filter(h_LEM_2', 1, farEndSignal(hSwitchAt-windowlen/4+1:hSwitchAt+windowlen/4),states);
                        echoSignal(hSwitchAt-windowlen/4+1:hSwitchAt+windowlen/4) = echoSignal(hSwitchAt-windowlen/4+1:hSwitchAt+windowlen/4)+temp.*window(1:windowlen/2);
                        echoSignal(hSwitchAt+windowlen/4+1:end) = filter(h_LEM_2', 1, farEndSignal(hSwitchAt+windowlen/4+1:end),states);
                        clear temp window windowlen states;
                        
                        echoSignal = factorFES*echoSignal.';
                        farEndSignal = farEndSignal.';
                        
                        saveFileName = ['echoSignal_DE_' databaseFile(speaker).name '_' num2str(farEndIndex) '.mat'];
                        saveAudioName = ['echoSignal_DE_' databaseFile(speaker).name '_' num2str(farEndIndex) '.raw'];
                        save(saveFileName,'echoSignal');
                        saveshort(echoSignal,saveAudioName);
                        
                        farEndSignal = [];
                    end
                end % end for "for speechFileIndex"
            end % end for "if databaseFile(j).isdir"
        end %end for "if ~strcmp"
    end % end for "for speaker"
end % end for "for subdirIndex"

pause;