function [filtvel, filtacc, nativevel] = cal_filtvelacc(h,v,span)
% cal_filtvelacc filters horizontal and vertical eye position vectors
% through Savitzky-Golay Filters and returns velocity and acceleration.

% Code based on EventDetector 1.0 from Marcus Nyström and Kenneth
% Holmqvist.
% See Behav Res Methods. 2010 Feb;42(1):188-204.
% Modified for use in Sommer lab recording setup - VP 11/2011

% Calculate unfiltered data
%--------------------------------------------------------------------------
nativeh = h;
nativev = v;

nativehvel = diff(h);
nativevvel = diff(v);
nativevel = sqrt(nativehvel.^2 + nativevvel.^2);

% Pixel values, velocities, and accelerations
%--------------------------------------------------------------------------
N = 2;                 % Order of polynomial fit
F = 2*ceil(span)-1;    % Window length
[b,g] = sgolay(N,F);   % Calculate S-G coefficients

% Calculate the velocity and acceleration
% filth=filter(g(:,1),1,h);
% filtv=filter(g(:,1),1,v);

filthvel=filter(g(:,2),1,h); 
filtvvel=filter(g(:,2),1,v);
filtvel=sqrt(filthvel.^2 +filtvvel.^2);

filthacc=filter(g(:,3),1,h); 
filtvacc=filter(g(:,3),1,v);
filtacc=sqrt(filthacc.^2 +filtvacc.^2);