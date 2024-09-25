%% Processing recordings
clear all;
close all;

% Constants
c = 299e6; % (m/s) speed of light
fc = 2590e6; % (Hz) Center frequency (connect VCO Vtune to +5)

%Input Variables
CPI = 0.25;
maxSpeed_m_s = 50; % (km/hr) maximum speed to display
RecordingNo2Process = 14; 

PFA = 10^-3;    % Probability of False Alarm
RefWindow = 64; % Reference Window or CFAR Window
Training = RefWindow/2;  %training cells
guard = 4; %guard cells

wavFile_CW_All = {'moving1.wav';
                   'moving2.wav';
                   'moving3.wav';
                   'moving4.wav';
                   'moving5.wav';
                   'moving6.wav';
                   'moving7.wav';
                   'moving8.wav';
                   'moving9.wav';
                   'moving10.wav';
                   'moving11.wav';
                   'moving12.wav';
                   'moving13.wav';
                   'moving14.wav'};
              
wavFile = wavFile_CW_All{RecordingNo2Process};

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
NumSamplesPerFrame =  2^(nextpow2(round(CPI*fs)));      % Ensure its a power of 2-p[
OverlapFactor = 0.75;                                    % Overlap factor between successive frames 

[S, f, t] = Ethan_Spectrogram(y,fs, NumSamplesPerFrame, OverlapFactor);


speed_m_per_sec = f*lamda/2;
speed_m_per_s_Idx = find((speed_m_per_sec <= maxSpeed_m_s) & (speed_m_per_sec >= 0));

SpeedVectorOfInterest = speed_m_per_sec(speed_m_per_s_Idx);
S_OfInterest = S(speed_m_per_s_Idx, :);

S_OfInterestToPlot = abs(S_OfInterest)/max(max(abs(S_OfInterest)));

%Test variables to select certain columns to test CFAR algorithm
S_FewColumns = S_OfInterestToPlot(:,:);
t_few = t(:,:);

[DataAfterPowerLawDetector, Threshold, detections] = Ethan_CFAR(S_FewColumns, PFA, RefWindow, Training, guard);

[rowidx, colidx] = find(detections); % finding detections for indexing

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
