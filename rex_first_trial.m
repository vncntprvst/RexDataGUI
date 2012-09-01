function [firsttrial] = rex_first_trial( name, num, includebad )

% [firsttrial] = rex_first_trial( name, includebad )
% 
%  Given a data set name (the name of the original REX data and/or the
%  matlab data file), return the number of the first trial.  If the
%  optional 2nd parameter 'includebad' is set to 1, then rex_first_trial()
%  simply returns the value 1 (assuming at least 1 trial exists).  If
%  'includebad' is 0 (the DEFAULT), then the trials are searched for the
%  first one that is not marked BAD, and the number of that trial is
%  returned.

%  EXAMPLE:
%
%  rexname = 'monkeydata';  % This will look for 'monkeydata.mat' or
%                           % 'monkeydataA' and '...E'
%  rex_load_processed( rexname );
%  trial = rex_first_trial( rexname );
%  if trial > 0
%     islast = 0;
%     while ~islast
%         [... make calls to things like rex_trial( rexname, trial ) to get
%         data for this trial ...]
%         [trial, islast] = rex_next_trial( rexname, trial );
%     end;
%  end;
%
%  Add a 1 as another parameter when calling rex_first_trial() and
%  rex_next_trial(), and this example will look at all trials, not just
%  those that are good (not marked as BAD).

if nargin < 2
    includebad = 0;
end

firsttrial = 0;

%num = num_rex_trials( name ); why call a function when you can pass an
%argument? 
if num == 0
    return;
end;

if includebad
    firsttrial = 1;
    return;
end;

badtrial = 1;
trial = 1;
while badtrial && trial < num
    badtrial = rex_is_bad_trial( name, trial );
    if badtrial
        trial = trial + 1;
    else
        firsttrial = trial;
    end;
end;
