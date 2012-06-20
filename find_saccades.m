function [starttimes, endtimes, ederiv] = find_saccades( h, v, minwidth, slope )%, sacth )

% Need to  add a saccade size threshold. Plus, make pop-up interface with menus
% to define parameters when rex_process is called.
% That would allow for more flexibility for different tasks and monkeys.

% [starttimes, endtimes, ederiv] = find_saccades( h, v, minwidth, slope )
%
% Given horizontal and vertical eye movement vectors (h and v), find where
% saccades occur.  Detection is based on thresholds for movement rate for 
% a minimum amount of time (minwidth).  Returns indices into the arrays
% h and v for when saccades start and another array for when they end.
% Thus h( starttimes(1):endtimes(1) ) would be the values in h (the
% horizontal component) during the
% first detected saccade, and v( starttimes(1):endtimes(1) ) would be the
% vertical component of that same first saccade.  Values in starttimes and
% endtimes are returned as indices.

if nargin < 3   %% duration threshold
    minwidth = 5;
end;
if nargin < 4   %% velocity threshold
    slope = 0.025;
end;
% if nargin < 5
     sacth = 2; %% size threshold
% end;

found = 0;
newstartingpoint = 0;

while ~found
    starttimes = [];
    endtimes = [];
    ederiv = [];

    if isempty( h ) || isempty( v )
        return;
    end;

    dh = diff( h );
    dv = diff( v );
    ederiv = sqrt( ( dh .* dh ) + ( dv .* dv ) );
    
    %currh=h;
    %currv=v;
    
    %  Find first valid saccade.

    last = length( ederiv );
    fs = find( ederiv > slope );
    if isempty( fs )
        return;
    end;
    fe = find( ederiv( fs(1):last ) < slope );
    if isempty( fe )
        return;
    end;
    fe = fe + fs( 1 ) - 1;
    
    swide = fe(1) - fs( 1 );
    shsize = abs(h(fe(1)) - h(fs( 1 )));
    svsize = abs(v(fe(1)) - v(fs( 1 )));
           
        if (swide >= minwidth) && (shsize > sacth || svsize > sacth)
            starttimes = fs( 1 );
            endtimes = fe( 1 );
            
            %  somewhere around here we want to find the next one with a recursive
            %  call.
            
            [nextstarttimes, nextendtimes] = find_saccades( h(fe(1):last), v(fe(1):last), minwidth, slope );
            
            starttimes = starttimes + newstartingpoint;
            endtimes = endtimes + newstartingpoint;
        
            if ~isempty( nextstarttimes )
                nextstarttimes = nextstarttimes + endtimes - 1;%(fe(1)-1) + newstartingpoint;
                nextendtimes = nextendtimes + endtimes - 1;%(fe(1)-1) + newstartingpoint;
                starttimes = cat( 1, starttimes, nextstarttimes );
                endtimes = cat( 1, endtimes, nextendtimes );
            end;
            found = 1;
            
            return;
        else
            newh = h(fe(1)+1:last);
            newv = v(fe(1)+1:last);
            found = 0;
            newstartingpoint = newstartingpoint + fe(1);
            h = newh;
            v = newv;
        end;
end;

%  If it isn't big enough, do a recursive call with the rest of the arrays.

%  Change 10 07 2009.  Apparently Matlab is lame and can't handle a
%  recursion depth beyond 500.  So this will have to be done iterively.

% [starttimes, endtimes] = find_saccades( h(fe(1):last), v(fe(1):last), minwidth, slope );
% if ~isempty( starttimes )
%     starttimes = starttimes + fe(1)-1;
%     endtimes = endtimes + fe(1)-1;
% else
%     starttimes = [];
%     endtimes = [];
% end;
