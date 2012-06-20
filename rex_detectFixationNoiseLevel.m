function [peakDetectionThreshold, saccadeVelocityTreshold, velPeakIdx] = rex_detectFixationNoiseLevel(minfixdur, InitialVelPeakIdx, Saccvel)
 
% New saccade detection code based on EventDetector 1.0 from Marcus Nyström and Kenneth Holmqvist.
% See Behav Res Methods. 2010 Feb;42(1):188-204.
% Modified for use in Sommer lab recording setup - VP 11/2011

possibleFixationIdx = ~InitialVelPeakIdx;
fixLabeled = bwlabel(possibleFixationIdx);

% Process one inter-peak-saccadic periods (called fixations below,
% although they are not identified as fixations yet). 
fixNoise = [];
for k = 1:max(fixLabeled)

    % The samples related to the current fixation
    fixIdx = find(fixLabeled == k);
    
    % Check that the fixation duration exceeds the minimum duration criteria. 
    if length(fixIdx)<minfixdur
        continue    
    end
    
    % Extract the samples from the center of the fixation
    centralFixSamples = minfixdur/6;
    fNoise = Saccvel(floor(fixIdx(1)+centralFixSamples):ceil(fixIdx(end)-centralFixSamples));
    fixNoise = [fixNoise fNoise];
end

avgNoise = nanmean(fixNoise);
stdNoise = nanstd(fixNoise);

% Base the peak velocity threshold on the noise level
peakDetectionThreshold =  avgNoise + 6*stdNoise;
saccadeVelocityTreshold = avgNoise + 3*stdNoise;
velPeakIdx  = Saccvel > peakDetectionThreshold;
