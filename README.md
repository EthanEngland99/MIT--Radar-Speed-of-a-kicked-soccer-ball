# Development of an Experimental Radar System for Estimating the Speed of a Kicked Soccer Ball

This repository is a collection of all code and data need to process Radar (.wav) data files recorded on the MIT coffee can radar and IPM-165 Radar Module. The code includes a functions that process the data for displaying on a Spectrogram, converting frequency to speed and using a Cell-Averaging Constant False Alarm Rate detection algorithm to find usefull data and overlay X's on the spectrogram for clarity

Steps to run the code and produce spectrogram:
1. Ensure all code(.m files) are saved/downloaded in the same file location as the example recordings(.wav files).
2. Open "Processing_recordings1.m in MATLAB.
3. Change RecordingNo2Process to the number of the example recording you would like to run, as commented in the code.
4. Run the code.
