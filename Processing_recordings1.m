%% Processing recordingsclear all;
close all;

% Constants
c = 299e6; % (m/s) speed of light
fc = 2590e6; % (Hz) Center frequency (connect VCO Vtune to +5)
%fc = 24e9;

%Input Variables
CPI = 0.1;
maxSpeed_m_s = 25; % (m/s) maximum speed to display
minSpeed_m_s = 0; % (m/s) minimum speed to display
RecordingNo2Process = 1;  % change to select file to run (1 = '5m1.wav', 2 = '10m1.wav', 3 = '20m1.wav', 4 = '30m1.wav')

PFA = 10^-5;    % Probability of False Alarm
RefWindow = 16; % Reference Window or CFAR Window
guard = 2; %guard cells
Training = RefWindow/2 -guard/2;  %training cells

wavFile_CW_All = {'5m1.wav';
                 '10m1.wav';
                 '20m1.wav';
                 '30m1.wav'};


wavFile = wavFile_CW_All{RecordingNo2Process};

% computations
lamda = c/fc;

% use a default filename if none is given
if ~exist('wavFile','var')
    wavFile = 'radar_test2.wav';
end

% read the raw WAV data
fprintf('Loading WAV file...\n');
[Y,fs] = audioread(wavFile,'native');
y = -Y(:,2); % Received signal at baseband

% Compute the spectrogram 
N =  2^(nextpow2(round(CPI*fs)));      % Ensure its a power of 2-p
OverlapFactor = 0.9;                                   % Percentage Overlap factor between successive frames 

[S, f, t] = Ethan_Spectrogram(y,fs, N, OverlapFactor);

%Converting Frequency to speed[m/s=]
speed_m_per_sec = f*lamda/2;
speed_m_per_s_Idx = find((speed_m_per_sec <= maxSpeed_m_s) & (speed_m_per_sec >= minSpeed_m_s));

SpeedVectorOfInterest = speed_m_per_sec(speed_m_per_s_Idx);
S_OfInterest = S(speed_m_per_s_Idx, :);

S_OfInterestToPlot = abs(S_OfInterest)/max(max(abs(S_OfInterest)));

[detections,threshold, DataAfterSquareLawDetector] = Ethan_CFAR(S_OfInterestToPlot, PFA, RefWindow, Training, guard);

[rowidx, colidx] = find(detections); % finding detections for indexing

% Plot the spectrogram
clims = [-50 0];
figure;
imagesc(t,SpeedVectorOfInterest,20*log10(S_OfInterestToPlot), clims);
xlabel('Time (s)');
ylabel('Speed (m/s)');
grid on;
colorbar;
colormap('jet');
axis xy;
hold on;
plot(t(colidx-1), SpeedVectorOfInterest(rowidx),  'kx');
hold off;

