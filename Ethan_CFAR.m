function[DataAfterPowerLawDetector, Threshold, detections] = Ethan_CFAR(S_FewColumns, f, t)

% len = 100000;   % Signal Length
PFA = 10^-3;    % Probability of False Alarm
RefWindow = 64; % Reference Window or CFAR Window
Training = RefWindow/2;  %training cells
guard = 4;


DataAfterPowerLawDetector = abs(S_FewColumns).^2;

[fin, numCols] = size(S_FewColumns);

alphaCA = RefWindow*(PFA^(-1/RefWindow) - 1); % alpha (CFAR) constant calculation 

Threshold = zeros(fin,numCols);  %initialising threshold matrix
g = zeros(fin,numCols); % initialising g_hat matrix
detections =  zeros(fin, numCols);

% numFalseAlarm = 0; % starting number for false alarm detections

for col = 1:numCols
    for CUT = Training + guard+1 : fin-Training-guard
        laggingWindow = CUT-Training-guard : CUT-guard-1; %Lagging window Index
        leadingWindow = CUT+guard+1 : CUT+Training+guard; % Leading window index

        g(CUT, col) = (sum(DataAfterPowerLawDetector(laggingWindow,col)) + sum(DataAfterPowerLawDetector(leadingWindow,col)))/RefWindow; %sum of leading window + sum of lagging window
     
        Threshold(CUT,col) = alphaCA*g(CUT,col); % populating the threshold matrx

        if DataAfterPowerLawDetector(CUT,col) > Threshold(CUT,col) % If a signal is detected above the threshold, count one extra into CFARout
            %numFalseAlarm = numFalseAlarm + 1;
            detections(CUT,col) = 1;
        end

    end
end

% PFA_Simulation = numFalseAlarm/(fin*tin);
% PFA_error = abs((PFA - PFA_Simulation)/PFA*100);
% 
% disp("Simulation PFA: " + PFA_Simulation)
% disp("PFA Error: " + PFA_error)
end

