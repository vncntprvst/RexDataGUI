function [filth, filtv, filtvel, filtacc, nativevel, nativeacc] = cal_velacc(heye,veye,span)
% cal_filtvelacc filters horizontal and vertical eye position vectors
% through Savitzky-Golay Filters and returns velocity and acceleration.

% Code based on EventDetector 1.0 from Marcus Nyström and Kenneth
% Holmqvist.
% See Behav Res Methods. 2010 Feb;42(1):188-204.
% Modified for use in Sommer lab recording setup - VP 11/2011

if (nargin<3)
    span=5;
end

if ~isrow(heye) %this script and subsequent saccade detection scripts work with row vectors, not columns
    heye=heye'; %however, rex_trial_raw, called in rex_process and rex_process_gaptask returns h and v
    veye=veye'; %as column vectors. So had to fix it here.
end

% Pixel values (if eye tracsker), velocities, and accelerations
%--------------------------------------------------------------------------
N = 2;                 % Order of polynomial fit
F = 2*ceil(span)-1;    % Window length
[b,g] = sgolay(N,F);   % Calculate S-G coefficients

% Calculate the velocity and acceleration
filth=filter(g(:,1),1,heye);
filtv=filter(g(:,1),1,veye);
filth(1:length(filth)-4)=filth(5:length(filth)); %rough compensation for the ~4ms lag
filtv(1:length(filtv)-4)=filtv(5:length(filtv)); %rough compensation for the ~4ms lag

filthvel=filter(g(:,2),1,heye); 
filtvvel=filter(g(:,2),1,veye);
filtvel=sqrt(filthvel.^2 +filtvvel.^2);
filtvel(1:length(filtvel)-4)=filtvel(5:length(filtvel)); %rough compensation for the ~4ms lag

filthacc=filter(g(:,3),1,heye); 
filtvacc=filter(g(:,3),1,veye);
filtacc=sqrt(filthacc.^2 +filtvacc.^2);
filtacc(1:length(filtacc)-4)=filtacc(5:length(filtacc)); %rough compensation for the ~4ms lag

% Calculate unfiltered data
%--------------------------------------------------------------------------

nativeh = heye;
nativev = veye;

nativehvel = diff(heye);
nativevvel = diff(veye);
nativevel = sqrt(nativehvel.^2 + nativevvel.^2);

nativehacc = diff(nativehvel);
nativevacc = diff(nativevvel);
nativeacc = sqrt(nativehacc.^2 + nativevacc.^2);

nativevel(1,length(filtacc))=nativevel(1,length(filtacc)-1); 
nativeacc(1,length(filtacc))=nativeacc(1,length(filtacc)-2); 