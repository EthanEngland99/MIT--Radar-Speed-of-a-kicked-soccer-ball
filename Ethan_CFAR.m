function[DataAfterSquareLawDetector, Threshold, detections] = Ethan_CFAR(S_FewColumns,PFA, RefWindow, Training, guard)


DataAfterSquareLawDetector = abs(S_FewColumns).^2; % Data after Square Law Detector (|S|^2)

[fin, numCols] = size(S_FewColumns); %calculating size of matrices needed

alphaCA = RefWindow*(PFA^(-1/RefWindow) - 1); % alpha (CFAR) constant calculation 

Threshold = zeros(fin,numCols);  %initialising threshold matrix
g = zeros(fin,numCols); % initialising g_hat matrix
detections =  zeros(fin, numCols); % initialising detection matrix

for col = 1:numCols
    for CUT = Training + guard+1 : fin-Training-guard %calculating the Cell Under Test
        laggingWindow = CUT-Training-guard : CUT-guard-1; %Lagging window Index
        leadingWindow = CUT+guard+1 : CUT+Training+guard; % Leading window index
        
        %sum of leading window + sum of lagging window
        g(CUT, col) = (sum(DataAfterSquareLawDetector(laggingWindow,col)) + sum(DataAfterSquareLawDetector(leadingWindow,col)))/RefWindow; 
     
        Threshold(CUT,col) = alphaCA*g(CUT,col); % populating the threshold matrx

        if DataAfterSquareLawDetector(CUT,col) > Threshold(CUT,col) % If a signal is detected above the threshold, count one extra into CFARout
            detections(CUT,col) = 1; % adding 1 to detections matrix for each data point > theshold
        end

    end
end
end

