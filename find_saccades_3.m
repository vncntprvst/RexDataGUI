function [saccadeInfo, saccadeIdx] = find_saccades_3(trialnb,Saccvel,Saccacc,velPeakIdx,minwidth,minfixwidth,saccadeVelocityTreshold,peakDetectionThreshold,heye,veye)

% Same idea as previous saccade detection codes: 
% Given horizontal and vertical eye movement vectors (h and v), find where
% saccades occur.  Detection is based on thresholds for movement rate for 
% a minimum amount of time (minwidth).  Returns indices into the arrays
% h and v for when saccades start and another array for when they end.
% Thus h( saccadeStartIdx(1):saccadeEndIdx(1) ) would be the values in h (the
% horizontal component) during the first detected saccade, 
% and v( saccadeStartIdx(1):saccadeEndIdx(1) ) would be the vertical component 
% of that same first saccade.  Values in starttimes and endtimes 
% are returned as indices.

% This new saccade detection code is based on EventDetector 1.0 from Marcus Nyström and Kenneth Holmqvist
% and modified for use in Sommer lab recording setup.
% See Behav Res Methods. 2010 Feb;42(1):188-204.
% VP 11/2011
global saccadeInfo;
saccadeInfo=struct('status',[],'starttime',[],'endtime',[],'duration',[],'amplitude',[],...
    'direction',[],'peakVelocity',[],'peakAcceleration',[],'latency',[]);

verbose=0;

len = length(Saccvel);

% Preallocate memory
velLabeled = bwlabel(velPeakIdx);
saccadeIdx = zeros(1,len);    % Saccade index
glissadesIdx = zeros(1,len);  % Glissade index
localsaccadeVelocityTreshold=NaN(1,max(velLabeled));
starttime = [];
startend = [];

saccadeInfo(trialnb,1).status='inprocess';

% If no saccades are detected, return
if ~logical(sum(velLabeled))
    if verbose
    disp('find_saccades_3 says: no saccade detected');
    end
    saccadeInfo(trialnb,1).status='no_saccade'; %still needs to fill the row with some info, otherwise
                                                %calls to this index value of saccadeInfo will return error    
else

% Process one velocity peak at the time
peak = 1;

for k = 1:max(velLabeled)

    %----------------------------------------------------------------------  
    % Check the saccade peak samples
    %----------------------------------------------------------------------       
    % The samples related to the current saccade
    peakIdx = find(velLabeled == k);
    
    % If the peak consists of =< minPeakSamples consecutive samples, it it probably
    % noise (1/6 or the min saccade duration)
    minPeakSamples = ceil(minwidth/6); 
    if length(peakIdx) <= minPeakSamples
            if verbose
                disp('find_saccades_3: length(peakIdx) <= minPeakSamples');
            end
        saccadeInfo(trialnb,peak).status='noise_or_saccade_too_short';
        continue
    end
    
    % Check whether this peak is already included in the previous saccade
    % (can be like this for glissades)
    if peak > 1
        if ~isempty(intersect(peakIdx,[find(saccadeIdx) find(glissadesIdx)]))
            if verbose
                disp('find_saccades_3: peak already included in the previous saccade');
            end
            saccadeInfo(trialnb,peak).status='peak_in_previous_saccade';
            continue
        end       
    end
       
    %----------------------------------------------------------------------
    % DETECT SACCADE
    %----------------------------------------------------------------------       
    
    % Detect saccade start.  AND acc <= 0
    saccadeStartIdx = find(Saccvel(peakIdx(1):-1:1) <= saccadeVelocityTreshold &...% vel <= global vel threshold
                                                 [diff(Saccvel(peakIdx(1):-1:1)) 0] >= 0);          % acc <= 0
                                             
    if isempty(saccadeStartIdx)
            if verbose
                disp('find_saccades_3: empty saccadeStartIdx');
            end
        saccadeInfo(trialnb,peak).status='cannot_detect_sacc_start';
        continue
% following code was designed to avoid late detection but lead to too many artifitial early detection         
%    elseif length(saccadeStartIdx)>=10 && saccadeStartIdx(2)-saccadeStartIdx(1)>1 % if it is isolated value, might lead to 'late' detection
%        for i=3:10
%                 diffsSI=saccadeStartIdx(i)-saccadeStartIdx(i-1);
%                     if diffsSI==1 && saccadeStartIdx(i-1)-saccadeStartIdx(1)<20
%                         saccadeStartIdx(1:i-1)=saccadeStartIdx(i-1);
%                     continue
%                     end
%                 morediffsSI=saccadeStartIdx(i)-saccadeStartIdx(i-2);
%                     if morediffsSI==2 && saccadeStartIdx(i-1)-saccadeStartIdx(1)<20
%                         saccadeStartIdx(1:i-2)=saccadeStartIdx(i-2);
%                     continue
%                     end
%        end
    end
    
    saccadeStartIdx = peakIdx(1) - saccadeStartIdx(1) + 1;
    
    % Calculate local fixation noise (the adaptive part, 30% local + 70% global)
    localVelNoise = Saccvel(saccadeStartIdx:-1: max(1,ceil(saccadeStartIdx - minfixwidth)));
    localVelNoise = mean(localVelNoise) + 3*std(localVelNoise);
    localsaccadeVelocityTreshold(peak)= localVelNoise*0.3 + saccadeVelocityTreshold*0.7; 
    
    % Check whether the local vel. noise exceeds the peak vel. threshold.
    if localVelNoise > peakDetectionThreshold
            if verbose
                disp('find_saccades_3: local velocity noise exceeds the peak velocity threshold');
            end
            saccadeInfo(trialnb,peak).status='high_local_velocity_noise';
        continue
    end
              
    % Detect end of saccade (without glissade)
    saccadeEndIdx = find(Saccvel(peakIdx(end):end) <= localsaccadeVelocityTreshold(peak)&...             % vel <= adaptive vel threshold
                                                  [diff(Saccvel(peakIdx(end):end)) 0] >= 0);        % acc <= 0
    
    if isempty(saccadeEndIdx)
            if verbose
                disp('find_saccades_3: empty saccadeEndIdx');
            end
            saccadeInfo(trialnb,peak).status='cannot_detect_end_sacc';
        continue
    end      
    saccadeEndIdx = peakIdx(end) + saccadeEndIdx(1) - 1;
    
    % If the saccade contains NaN samples, continue %not used here
    % if any(ETparams.nanIdx(i,j).Idx(saccadeStartIdx:saccadeEndIdx)), continue, end
        
    % Make sure the saccade duration exceeds the minimum duration.
    saccadeLen = saccadeEndIdx - saccadeStartIdx;
    if saccadeLen < minwidth
            if verbose
                disp('find_saccades_3: saccade duration below minimum duration');
            end
            saccadeInfo(trialnb,peak).status='low_sacc_duration';
        continue    
    end
%     

%     if ~ischar(saccadeInfo(trialnb,peak).status)
%         s = sprintf('trial nb %d, peak %d, all conditions fulfilled',trialnb,peak);
%         disp(s);
%     end
%         

% for small saccades, check if it's not a first step of a double step
% saccade, where the second (possibly larger step may go undetected because
% the localVelNoise would be too high

% >>>> this code works, but change it so that it detects multiple saccades
% and not a big one

%sacamp=sqrt((heye(saccadeEndIdx)-heye(saccadeStartIdx))^2 + (veye(saccadeEndIdx)-veye(saccadeStartIdx))^2); 

%     if sacamp<3 && k~=max(velLabeled)
%         for i=k:max(velLabeled)-1
%             nextsacs(i)=find(velLabeled==i+1,1);
%         end
%         if logical(sum(nextsacs-saccadeEndIdx<30)) %30ms interval - arbitrary (real case example 24)
%             plateauVelNoise = Saccvel(saccadeEndIdx:nextsacs(find((nextsacs-saccadeEndIdx<30),1,'last'))); % a little bit complicated: in case there multiple successive peaks
%             plateauVelNoise = mean(plateauVelNoise) + 3*std(plateauVelNoise);
%             if plateauVelNoise > peakDetectionThreshold % that is next sac risks not being detected
%                 formersaccadeEndIdx=saccadeEndIdx;
%                 peakIdx=nextsacs(find((nextsacs-saccadeEndIdx<30),1,'last'));
%                 saccadeEndIdx = find(Saccvel(peakIdx:end) <= localsaccadeVelocityTreshold(peak)&... % vel <= adaptive vel threshold
%                     [diff(Saccvel(peakIdx:end)) 0] >= 0);        % acc <= 0
%                 if isempty(saccadeEndIdx) %too bad, nice try
%                     saccadeEndIdx=formersaccadeEndIdx;
%                 else
%                     saccadeEndIdx = peakIdx(end) + saccadeEndIdx(1) - 1;
%                 end
%             end
%         end
%     end %victoire - pfiou
        

    % If all the above criteria are fulfilled, label it as a saccade.
    saccadeIdx(saccadeStartIdx:saccadeEndIdx) = 1;
 
    % Collect information about the saccade %need good system to store info
    % for each saccade
    saccadeInfo(trialnb,peak).starttime = saccadeStartIdx; % in ms
    saccadeInfo(trialnb,peak).endtime = saccadeEndIdx; % in ms
    saccadeInfo(trialnb,peak).duration = saccadeInfo(trialnb,peak).endtime - saccadeInfo(trialnb,peak).starttime;
    
    % saccades leftward are negative amplitude ... corrected below
    sacamp=sqrt(((heye(saccadeEndIdx)-(heye(saccadeStartIdx))))^2 + ...
                ((veye(saccadeEndIdx)-(veye(saccadeStartIdx))))^2);  
            
    sacdeg=abs(atand((heye(saccadeEndIdx)-(heye(saccadeStartIdx)))/(veye(saccadeEndIdx)-(veye(saccadeStartIdx)))));
    
%     if trialnb==104
%         sacdeg
%         figure(21)
%         plot(heye(saccadeStartIdx:saccadeEndIdx));
%         hold on;
%         plot(veye(saccadeStartIdx:saccadeEndIdx),'r');
%         hold off
%     end
    
    % sign adjustements
    if veye(saccadeEndIdx)<veye(saccadeStartIdx) % negative vertical amplitude -> vertical flip
    	sacdeg=180-sacdeg;
    end
    
    if heye(saccadeEndIdx)>heye(saccadeStartIdx)%inverted signal: leftward is in postive range. Correcting to negative. 
        sacamp=-sacamp;
        sacdeg=360-sacdeg; % mirror image;
    end
      
            
    saccadeInfo(trialnb,peak).amplitude=sacamp;
    saccadeInfo(trialnb,peak).direction=sacdeg;
    saccadeInfo(trialnb,peak).peakVelocity = max(Saccvel(saccadeStartIdx:saccadeEndIdx)); 
    saccadeInfo(trialnb,peak).peakAcceleration = max(Saccacc(saccadeStartIdx:saccadeEndIdx)); 
    saccadeInfo(trialnb,peak).status='saccade';
                                             
    peak = peak+1;
end
end
