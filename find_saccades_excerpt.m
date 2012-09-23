function sacfound = find_saccades_excerpt(next,newpeak,excs,exce,Saccvel,Saccacc,minwidth,minfixwidth,saccadeVelocityTreshold,peakDetectionThreshold,heye,veye)
global saccadeInfo;
% find_saccade_3 redux

% Preallocate memory
len = length(Saccvel);
saccadeIdx = zeros(1,len);    % Saccade index
glissadesIdx = zeros(1,len);  % Glissade index
localsaccadeVelocityTreshold=NaN(1,1);
starttime = [];
startend = [];
peakDetectionThreshold=1.2*peakDetectionThreshold;


% The samples related to the current period, minus the little time
% added previously
peakIdx = find(Saccvel==(max(Saccvel)))-5:find(Saccvel==(max(Saccvel)))+5;

% If the period is =< minPeakSamples consecutive , it it probably
% noise (1/6 or the min saccade duration)
minPeakSamples = ceil(minwidth/6);
if length(peakIdx) <= minPeakSamples
    disp('find_saccades_excerpt: length(peakIdx) <= minPeakSamples');
    sacfound=0;
else
    
    %----------------------------------------------------------------------
    % DETECT SACCADE
    %----------------------------------------------------------------------
    
    % Detect saccade start.  AND acc <= 0
    saccadeStartIdx = find(Saccvel(peakIdx(1):-1:1) <= saccadeVelocityTreshold &...% vel <= global vel threshold
        [diff(Saccvel(peakIdx(1):-1:1)) 0] >= 0);          % acc <= 0
    
    if isempty(saccadeStartIdx)
        %disp('find_saccades_excerpt: empty saccadeStartIdx');
        sacfound=0;
    else
        
        saccadeStartIdx = peakIdx(1) - saccadeStartIdx(1) + 1;
        
        % Calculate local fixation noise (the adaptive part, 30% local + 70% global)
        localVelNoise = Saccvel(saccadeStartIdx:-1: max(1,ceil(saccadeStartIdx - minfixwidth)));
        localVelNoise = mean(localVelNoise) + 3*std(localVelNoise);
        localsaccadeVelocityTreshold= localVelNoise*0.3 + saccadeVelocityTreshold*0.7;
        
        % Check whether the local vel. noise exceeds the peak vel. threshold.
        if localVelNoise > peakDetectionThreshold
            %disp('find_saccades_excerpt: local velocity noise exceeds the peak velocity threshold');
            sacfound=0;
        else
            
            % Detect end of saccade (without glissade)
            saccadeEndIdx = find(Saccvel(peakIdx(end):end) <= localsaccadeVelocityTreshold&...             % vel <= adaptive vel threshold
                [diff(Saccvel(peakIdx(end):end)) 0] >= 0);        % acc <= 0
            
            if isempty(saccadeEndIdx)
                % disp('find_saccades_excerpt: empty saccadeEndIdx');
                sacfound=0;
            else
                saccadeEndIdx = peakIdx(end) + saccadeEndIdx(1) - 1;
                
                % If the saccade contains NaN samples, continue %not used here
                % if any(ETparams.nanIdx(i,j).Idx(saccadeStartIdx:saccadeEndIdx)), continue, end
                
                % Make sure the saccade duration exceeds the minimum duration.
                saccadeLen = saccadeEndIdx - saccadeStartIdx;
                if saccadeLen < minwidth
                    %  disp('find_saccades_excerpt: saccade duration below minimum duration');
                    sacfound=0;
                else
                    %
                    
                    %     if ~ischar(saccadeInfo(trialnb,peak).status)
                    %         s = sprintf('trial nb %d, peak %d, all conditions fulfilled',trialnb,peak);
                    %         disp(s);
                    %     end
                    %
                    
                    % for small saccades, check if it's not a first step of a double step
                    % saccade, where the second (possibly larger step may go undetected because
                    % the localVelNoise would be too high
                    sacamp=sqrt(((heye(saccadeEndIdx)-(heye(saccadeStartIdx))))^2 + ...
                        ((veye(saccadeEndIdx)-(veye(saccadeStartIdx))))^2);
                    
                    sacdeg=abs(atand((heye(saccadeEndIdx)-(heye(saccadeStartIdx)))/(veye(saccadeEndIdx)-(veye(saccadeStartIdx)))));
                    
                    
                    % sign adjustements
                    if veye(saccadeEndIdx)<veye(saccadeStartIdx) % negative vertical amplitude -> vertical flip
                        sacdeg=180-sacdeg;
                    end
                    
                    if heye(saccadeEndIdx)>heye(saccadeStartIdx)%inverted signal: leftward is in postive range. Correcting to negative.
                        sacamp=-sacamp;
                        sacdeg=360-sacdeg; % mirror image;
                    end
                    
                    
                    %If all the above criteria are fulfilled
                    
                    if abs(sacamp)<2 % If  saccade too small
                        %disp('find_saccades_excerpt: saccade too small');
                        sacfound=0;
                    else
                        saccadeInfo(next,newpeak).starttime = excs+saccadeStartIdx;
                        saccadeInfo(next,newpeak).endtime = excs+saccadeEndIdx;
                        saccadeInfo(next,newpeak).duration = saccadeEndIdx - saccadeStartIdx;
                        saccadeInfo(next,newpeak).amplitude = sacamp;
                        saccadeInfo(next,newpeak).direction=sacdeg;
                        saccadeInfo(next,newpeak).peakVelocity = max(Saccvel(saccadeStartIdx:saccadeEndIdx));
                        saccadeInfo(next,newpeak).peakAcceleration = max(Saccacc(saccadeStartIdx:saccadeEndIdx));
                        saccadeInfo(next,newpeak).status='saccade';
                        sacfound=1;
                    end
                end
            end
        end
    end
end
