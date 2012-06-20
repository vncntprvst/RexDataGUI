function n = rex_numtrials_raw(name, includeaborted);

% function n = num_rex_trials(name);
% returns the number of SUCCESSFUL trials in an axpt
% by James R. Cavanaugh 2001

if ~nargin
	error('File name required in num_rex_trials()');
end;
if nargin < 2
    includeaborted = 0;
end;

if iscell(name)
	numnm = length(name);
else
	numnm = 1;
	name = {name};
end;

n = 0;

for n = 1:numnm

	[ecode, etime] = rex_ecodes(name);

	% trial start and aborts
	trialstart = find(ecode == 1001);
	trialabort = find(ecode == 17385);

    if includeaborted
        n = length( trialstart );
    else
    	n = length(trialstart) - length(trialabort);
    end;
end;

