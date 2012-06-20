function [nexttrial, islast] = rex_next_trial( name, trial, includebad )

% [nexttrial, islast] = rex_next_trial( name, trial, includebad )
% 
%  Given a data set name (the name of the original REX data and/or the
%  matlab data file), and a trial number, return the number (just the
%  number) of the next sequential trial.  If the optional 3rd parameter
%  'includebad' is set to 1, then this is simply trial + 1.  If the 3rd
%  parameter is 0 (the DEFAULT), then a search forward is done for the next
%  good trial (the next trial not marked as BAD), and rex_next_trial() 
%  returns that number.
%  In either instance, if no next trial number can be returned (the trial
%  value passed in is already the last one) then nexttrial is 0 and islast
%  is set to 1.
%
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

global rexnumtrials;

if nargin < 3
    includebad = 0;
end;

nexttrial = trial;
badtrial = 1;
islast = 0;

num = rexnumtrials; %num_rex_trials( name );

if trial >= num
    nexttrial = 0;
    islast = 1;
    return;
end;

if includebad
    nexttrial = nexttrial + 1;
%     if nexttrial == num
%         islast = 1;
%     end;
    return;
end;

while badtrial && nexttrial < num
    nexttrial = nexttrial + 1;
    badtrial = rex_is_bad_trial( name, nexttrial );
end;

% If no more good trials can be found, then badtrial will come out of the
% above loop still true.  It means that trial is already the last trial.

if badtrial
    nexttrial = 0;
    islast = 1;
    return;
end;

% % Is this the last good trial?
% 
% islast = 1;
% for d = nexttrial+1:num
%     badtrial = rex_is_bad_trial( name, d );
%     if ~badtrial
%         islast = 0;
%     end;
% end;

