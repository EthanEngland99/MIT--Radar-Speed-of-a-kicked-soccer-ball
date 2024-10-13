function [S, f, t] = Ethan_Spectrogram(y,fs, N, OverlapFactor)

    y = single(y(:));                                                       % Coverting the signal y to a column-vector 
    ylen = length(y) ;                                                      % length of signal y(t)
    w = hamming(N);                                                         % window function

    H = floor(N*OverlapFactor);
    hop = N - H;                                                            % Hop factor   
    NumOfFrames = 1 + floor((ylen-N)/(hop));                                % calculating number of total frames
    

    S = zeros(N,NumOfFrames);                                               % generate empty STFT matrix


    for Count_NumOfFrames = 1:(NumOfFrames)
        startIdx = 1+ (Count_NumOfFrames-1)*hop;                            % start index of frame
        stopIdx = startIdx + (N-1);                                         % stop index of frame
        
        % [startIdx stopIdx];
        
        y_w = y(startIdx:stopIdx).*w;                                       % hamming window applied before the fft
        y_w = y_w - mean(y_w);                                              % removal of DC component
    
        Yfft_w = fftshift(fft(y_w));                                        % fftshift used because the frequency axis has both positive and negative values
        S (:, 1+Count_NumOfFrames) = Yfft_w;                                % Updating STFT matrix  
     end 

    t = (N/2:hop:N/2+(NumOfFrames-1)*hop)/fs;                               % Time axis (s)
    f = (-N/2:1:(N/2-1))*fs/N;                                              % Frequency axis (kHz)
end
