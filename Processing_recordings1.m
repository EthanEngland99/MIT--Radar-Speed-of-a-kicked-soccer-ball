%% Processing recordings
clear all;
close all;

% Constants
c = 299e6; % (m/s) speed of light
fc = 2590e6; % (Hz) Center frequency (connect VCO Vtune to +5)

%Input Variables
CPI = 0.25;
maxSpeed_m_s = 25; % (km/hr) maximum speed to display
RecordingNo2Process = 3; 

wavFile_CW_All = {'Penalty kick 1.wav'; 
                  'Penalty kick 2.wav';
                  'Penalty kick 3.wav';
                  'Penalty kick 4.wav';
                  'Penalty kick 5.wav';
                  'Penalty kick 6.wav';
                  'Penalty kick 7.wav';
                  'Penalty kick 8.wav';
                  'Penalty kick 9.wav';
                  'Penalty kick 10.wav'};
              
wavFile = wavFile_CW_All{RecordingNo2Process};

% dataProcessing(wavFile_CW, CPI);

% computations
lamda = c/fc;

% use a default filename if none is given
if ~exist('wavFile','var')
    wavFile = 'radar_test2.wav';
end

% read the raw wave data
fprintf('Loading WAV file...\n');
[Y,fs] = audioread(wavFile,'native');
y = -Y(:,2); % Received signal at baseband


% Compute the spectrogram 
NumSamplesPerFrame =  2^(nextpow2(round(CPI*fs)));      % Ensure its a power of 2
OverlapFactor = 0.75;                                    % Overlap factor between successive frames 

[S, f, t] = Ethan_Spectrogram(y,fs, NumSamplesPerFrame, OverlapFactor);


speed_m_per_sec = f*lamda/2;
speed_m_per_s_Idx = find((speed_m_per_sec <= maxSpeed_m_s) & (speed_m_per_sec >= 0));

SpeedVectorOfInterest = speed_m_per_sec(speed_m_per_s_Idx);
S_OfInterest = S(speed_m_per_s_Idx, :);

S_OfInterestToPlot = abs(S_OfInterest)/max(max(abs(S_OfInterest)));

S_FewColumns = S_OfInterestToPlot(:,:);
t_few = t(:,:);

[DataAfterPowerLawDetector, Threshold, detections] = Ethan_CFAR(S_FewColumns, f, t);

[rowidx, colidx] = find(detections);
idx = [rowidx, colidx];

% Plot the spectrogram
clims = [-50 0];
figure;
imagesc(t,SpeedVectorOfInterest,20*log10(S_FewColumns), clims);
xlabel('Time (s)');
ylabel('Speed (m/s)');
grid on;
colorbar;
colormap('jet');
axis xy;
hold on;
plot(t_few(colidx), SpeedVectorOfInterest(rowidx),  'kx');
hold off;
